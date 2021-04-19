SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_windms_GetBulkGPS]      
AS     
 SET NOCOUNT ON;  
BEGIN      
 DECLARE @PreviousLastOperation smalldatetime;      
 DECLARE @TruckId bigint;      
 DECLARE @CustomerIntId int;      
 DECLARE @VehicleId uniqueidentifier;      
 DECLARE @nFirstCursorCheck int;      
 DECLARE @nSecondCursorCheck int;      
 DECLARE @Str_xmlns varchar(50);      
 DECLARE @TempResults TABLE(CustomerIntId int      
							,XmlDoc xml
							,EventDateTime datetime);      
      
 SET @Str_xmlns = 'http://www.ltrack.com:1115/XMLSchema/BulkGPS';      
 SET @nFirstCursorCheck = 0;      
       
 DECLARE TempSubscription CURSOR FAST_FORWARD READ_ONLY FOR      
 SELECT DISTINCT DepotId      
 FROM XMLDeliveryServiceBulkGPSDeliveryApp.dbo.NSBulkGPSSubscriptionsView Where DepotId <> 0      
      
 OPEN TempSubscription;      
 WHILE(0 = @nFirstCursorCheck)      
 BEGIN      
  FETCH NEXT FROM TempSubscription INTO @CustomerIntId;      
  SET @nFirstCursorCheck = @@FETCH_STATUS;      
  IF(0 = @nFirstCursorCheck)      
  BEGIN      
   DECLARE @TempGPSPoints TABLE([Tag] int      
          ,[Parent] int      
          ,[xmlns] varchar(50)      
          ,[TruckId2] bigint      
          ,[Lat] float        
          ,[Long] float        
          ,[Time] datetime        
          ,[Speed] smallint        
          ,[Heading] smallint        
          ,[Reason] smallint      
          ,[LastOperation] smalldatetime);      
    
	DELETE FROM @TempGPSPoints 
	     
   INSERT INTO @TempGPSPoints      
   VALUES (1      
     ,0      
     ,@Str_xmlns      
     ,NULL      
     ,NULL      
     ,NULL      
     ,NULL      
     ,NULL      
     ,NULL      
     ,NULL      
     ,NULL);      
      
   SET @nSecondCursorCheck = 0;      
      
   DECLARE TempVehicle CURSOR FAST_FORWARD READ_ONLY FOR      
   SELECT tv.VehicleId,      
     tv.TruckId      
   FROM windms_TrucksVehicles tv 
   INNER JOIN CustomerVehicle cv ON tv.VehicleId = cv.VehicleId      
   INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId     
   WHERE c.CustomerIntId = @CustomerIntId AND cv.EndDate IS NULL AND tv.Archived = 0;      
      
   OPEN TempVehicle;      
   WHILE(0 = @nSecondCursorCheck)      
   BEGIN      
    FETCH NEXT FROM TempVehicle INTO @VehicleId,@TruckId      
    SET @nSecondCursorCheck = @@FETCH_STATUS;      
    IF (0 = @nSecondCursorCheck)      
    BEGIN      
           
     IF (SELECT LastOperation FROM windms_LastGPSPoint WHERE [VehicleId] = @VehicleId AND LastOperation >= DATEADD(minute,-6,GETDATE())) IS NOT NULL         
     BEGIN          
      SET @PreviousLastOperation = (SELECT [LastOperation]          
              FROM windms_LastGPSPoint         
              WHERE [VehicleId] = @VehicleId);       
     END          
     ELSE          
     BEGIN          
      SET @PreviousLastOperation = DATEADD(minute,-6,GETDATE());          
     END 
		
		IF @PreviousLastOperation < DATEADD(minute,-6,GETDATE())
		BEGIN
			SET @PreviousLastOperation = DATEADD(minute,-6,GETDATE());
		END
            
     INSERT INTO @TempGPSPoints      
     VALUES (2      
       ,1      
       ,@Str_xmlns      
       ,@TruckId      
       ,NULL      
       ,NULL      
       ,NULL      
       ,NULL      
       ,NULL      
       ,NULL      
       ,NULL);      
      
     INSERT INTO @TempGPSPoints      
     SELECT 3,        
       2,       
       @Str_xmlns,      
       @TruckId,         
       Lat,        
       Long,        
       EventDateTime,        
       Speed,        
       Heading,        
       CreationCodeId,      
       LastOperation        
     FROM windms_EventsLatest
     WHERE CustomerIntId = @CustomerIntId        
       AND VehicleId = @VehicleId        
       AND LastOperation  between @PreviousLastOperation and LastOperation 
      
     SET @PreviousLastOperation  = (SELECT MAX(LastOperation) FROM @TempGPSPoints WHERE TruckId2 = @TruckId);          

	IF @PreviousLastOperation < DATEADD(minute,-6,GETDATE())
	BEGIN
		SET @PreviousLastOperation = DATEADD(minute,-6,GETDATE());
	END

	IF @PreviousLastOperation is null
	BEGIN
		SET @PreviousLastOperation = DATEADD(minute,-6,GETDATE());
	END

     UPDATE windms_LastGPSPoint          
     SET  [LastOperation] = @PreviousLastOperation          
     WHERE [VehicleId] = @VehicleId;          

     IF(@@Rowcount = 0)      
     BEGIN         
      INSERT INTO windms_LastGPSPoint          
         ([VehicleId]          
         ,[LastOperation]          
         ,[TruckId])          
      VALUES          
         (@VehicleId          
         ,@PreviousLastOperation          
         ,@TruckId);      
     END            
    END      
   END      
   CLOSE TempVehicle;      
   DEALLOCATE TempVehicle;      

	DECLARE @bulkgpslistcount int
	Select @bulkgpslistcount = count(*) FROM @TempGPSPoints Where TruckId2 is not null--added to prevent empty files being sent
	IF @bulkgpslistcount <> 0
	BEGIN
	   DECLARE @varXml xml;      
	   SET @varXml = (SELECT [Tag],[Parent],[xmlns] AS [BulkGPSList!1!xmlns],[TruckId2] AS [BulkGPS!2!TruckId],      
			 dbo.GPSCoord_DegMillionthsToDegMinFrac(ISNULL([Lat],0))  AS [GPSReport!3!Lat!element],      
			 dbo.GPSCoord_DegMillionthsToDegMinFrac(ISNULL([Long],0))  AS [GPSReport!3!Long!element],      
			 dbo.GPSCoord_DateToYYYYMMDDHHmmss(ISNULL([Time],0))  AS [GPSReport!3!Time!element],       
			 [Speed]  AS [GPSReport!3!Speed!element],[Heading] AS [GPSReport!3!Heading!element],[Reason] AS [GPSReport!3!Reason!element],
			 ISNULL((SELECT TOP 1 windms_Job.JobId 
				FROM windms_Shift
				INNER JOIN windms_Job ON windms_Job.ShiftId = windms_Shift.ShiftId
				WHERE windms_Shift.EstEndTime >= [Time] AND windms_Shift.EstStartTime < [Time] AND windms_Shift.TruckId = [TruckId2]),'')
				AS [GPSReport!3!JobId!element]  
		   FROM @TempGPSPoints   
		   FOR XML EXPLICIT,TYPE);      
	   INSERT INTO @TempResults      
	   VALUES (@CustomerIntId,@varXml,GETDATE());
	END
END      
END      
CLOSE TempSubscription;      
DEALLOCATE TempSubscription;      
     
SELECT * FROM @TempResults;      
END







GO
