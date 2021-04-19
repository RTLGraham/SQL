SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_TurnOffTheBuzzer]
(
	@vehicleId UNIQUEIDENTIFIER,
	@firstParam INT = 10800,
	@thirdParam INT = 60,
	@fourthParam INT = 0
)
AS
BEGIN
	-->STCXAT+RTLD=10800,0,60,0
	--'>STCXAT+RTLD=' + @firstParam + ',0,' + @thirdParam + ',' + @fourthParam
	DECLARE @ivh UNIQUEIDENTIFIER
	
	--Release IVH
	SELECT TOP 1 @ivh = IVHId 
	FROM dbo.Vehicle
	WHERE VehicleId = @vehicleId
	ORDER BY LastOperation DESC
	
	
	INSERT INTO dbo.VehicleCommand
	        ( IVHId ,
	          Command ,
	          ExpiryDate ,
	          AcknowledgedDate ,
	          LastOperation ,
	          Archived
	        )
	VALUES  ( @ivh , -- IVHId - uniqueidentifier
	          CAST('>STCXAT+RTLD=' + CAST(@firstParam AS VARCHAR(MAX)) + ',0,' + CAST(@thirdParam AS VARCHAR(MAX)) + ',' + CAST(@fourthParam AS VARCHAR(MAX)) AS BINARY(1024)) , -- Command - binary
	          DATEADD(DAY, 1, GETDATE()) , -- ExpiryDate - smalldatetime
	          NULL , -- AcknowledgedDate - smalldatetime
	          DATEADD(minute, -1, GETDATE()) , -- LastOperation - smalldatetime
	          0  -- Archived - bit
	        )
	        
	INSERT INTO dbo.VehicleCommand
	        ( IVHId ,
	          Command ,
	          ExpiryDate ,
	          AcknowledgedDate ,
	          LastOperation ,
	          Archived
	        )
	VALUES  ( @ivh , -- IVHId - uniqueidentifier
	          CAST('>STCXAT+RTLD?' AS BINARY(1024)) , -- Command - binary
	          DATEADD(DAY, 1, GETDATE()) , -- ExpiryDate - smalldatetime
	          NULL , -- AcknowledgedDate - smalldatetime
	          GETDATE() , -- LastOperation - smalldatetime
	          0  -- Archived - bit
	        )
END



GO
