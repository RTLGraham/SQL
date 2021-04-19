SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =========================================================================================
-- Author:		Graham Pattison
-- Create date: 28/02/2011
-- Description:	Insert successully matching potential triggers into TAN_NotificationsPending
-- =========================================================================================
CREATE PROCEDURE [dbo].[proc_TAN_AnalyseTriggers]
AS

BEGIN

	SET NOCOUNT ON;
    
    -- Process indicator values 0: Unprocessed 
	--							1: In Process 
	--							2: Awaiting Time Delay 
	--							3: Processed
	--							4: Cancelled
	--							5: Ignored (doesn't match any trigger configuration)
	-- (Processed, Cancelled and Ignored TriggerEvents may be deleted)
	
	-- set a variable to current datetime so that a consistent value is used throughout the procedure
	DECLARE @now DATETIME
	SET @now = GETUTCDATE()
    SET DATEFIRST 1 -- Ensure that Monday is set as the first day of the week when matching schedules
      
	-- Step 1 -- Mark all unprocessed rows in TAN_TriggerEvent as 'In Process'
	UPDATE TAN_TriggerEvent
	SET ProcessInd = 1
	WHERE ProcessInd = 0

	-- Step 2 -- Process against the TAN Parameters
	-- and INSERT successfully matching entries into the temporary @Notify table

	DECLARE @Notify TABLE
    (
		TriggerId UNIQUEIDENTIFIER,
		VehicleIntId INT,
		DriverIntId INT,
		GeofenceId UNIQUEIDENTIFIER,
		ApplicationId SMALLINT,
		Long FLOAT,
		Lat FLOAT,
		Heading SMALLINT,
		Speed SMALLINT,
		TripDistance INT,
		DataName VARCHAR(30),
		DataString VARCHAR(1024),
		DataInt INT,
		DataFloat FLOAT,
		DataBit BIT,
		EventId BIGINT,
		TriggerDateTime DATETIME,
		ProcessInd SMALLINT,
		TriggerEventId UNIQUEIDENTIFIER
	)

	INSERT INTO @Notify (TriggerId,VehicleIntId,DriverIntId,GeofenceId,ApplicationId,Long,Lat,Heading,Speed,TripDistance,DataName,DataString,DataInt,DataFloat,DataBit,EventId,TriggerDateTime,ProcessInd,TriggerEventId)
	SELECT	   t.TriggerId,
			   tev.VehicleIntId,
			   tev.DriverIntId,
			   tev.GeofenceId,
			   tev.ApplicationId,
			   tev.Long,
			   tev.Lat,
			   tev.Heading,
			   tev.Speed,
			   tev.TripDistance,
			   tev.DataName,
			   tev.DataString,
			   tev.DataInt,
			   tev.DataFloat,
			   tev.DataBit,
			   tev.EventId,
			   tev.TriggerDateTime,
			   CASE WHEN (tp6.TriggerId IS NULL OR DATEDIFF(mi, tev.TriggerDateTime, @now) >= CAST(tp6.TriggerParamTypeValue AS SMALLINT)) THEN 3 ELSE 2 END, -- Set Process Ind depending wehether time delay reached
			   tev.TriggerEventId

	FROM TAN_TriggerEvent tev

	-- match the creation code to determine the trigger type
	INNER JOIN TAN_TriggerType tt ON tev.CreationCodeId = tt.CreationCodeId
	
	-- match trigger type to find enabled triggers
	INNER JOIN TAN_Trigger t ON t.TriggerTypeId = tt.TriggerTypeId AND t.Disabled = 0 AND t.Archived = 0
	
	-- filter out if day not included in schedule (UTC times to be converted to user time zones)
	INNER JOIN TAN_TriggerSchedule ts ON t.TriggerId = ts.TriggerId AND ts.Archived = 0
			AND (DATEPART(dw, dbo.TZ_GetTime(tev.triggerdatetime, NULL, t.CreatedBy)) = ts.daynum OR ts.daynum = 0)
			
	-- filter against any matching trigger parameters:
	-- Join to determine entities to be included / excluded
	LEFT JOIN TAN_TriggerParam tpv ON tpv.TriggerId = t.TriggerId AND tpv.TriggerParamTypeId = 7 AND tpv.Archived = 0
	LEFT JOIN TAN_TriggerParam tpd ON tpd.TriggerId = t.TriggerId AND tpd.TriggerParamTypeId = 8 AND tpd.Archived = 0
	LEFT JOIN TAN_TriggerParam tpg ON tpg.TriggerId = t.TriggerId AND tpg.TriggerParamTypeId = 9 AND tpg.Archived = 0
	-- Join for all first start and end trigger times (type = 1 and 2)
	LEFT JOIN TAN_TriggerParam tp1 ON tp1.TriggerId = t.TriggerId AND tp1.TriggerParamTypeId = 1 AND tp1.Archived = 0
	LEFT JOIN TAN_TriggerParam tp2 ON tp2.TriggerId = t.TriggerId AND tp2.TriggerParamTypeId = 2 AND tp2.Archived = 0
	-- Join for all second start and end trigger times (type = 3 and 4)
	LEFT JOIN TAN_TriggerParam tp3 ON tp3.TriggerId = t.TriggerId AND tp3.TriggerParamTypeId = 3 AND tp3.Archived = 0
	LEFT JOIN TAN_TriggerParam tp4 ON tp4.TriggerId = t.TriggerId AND tp4.TriggerParamTypeId = 4 AND tp4.Archived = 0
	-- Join for any Repeat parameters (type = 5)
	LEFT JOIN TAN_TriggerParam tp5 ON tp5.TriggerId = t.TriggerId AND tp5.TriggerParamTypeId = 5 AND tp5.Archived = 0
	-- Join for any Delay parameters (type = 6)
	LEFT JOIN TAN_TriggerParam tp6 ON tp6.TriggerId = t.TriggerId AND tp6.TriggerParamTypeId = 6 AND tp6.Archived = 0
	
	-- Join for any currently checked out entities
	LEFT JOIN dbo.TAN_EntityCheckOut ec ON ec.Archived = 0
			AND (ec.EntityId = dbo.GetVehicleIdFromInt(tev.VehicleIntId) OR ec.EntityId = dbo.GetDriverIdFromInt(tev.DriverIntId))
			AND GETUTCDATE() BETWEEN ec.CheckOutDateTime AND ISNULL(ec.CheckInDateTime, '2099-21-31 00:00')
			
	-- Join to get latest trigger datetimes for entities
	LEFT JOIN dbo.TAN_TriggerEntityLatest tenl ON t.TriggerId = tenl.TriggerId
			AND (tenl.TriggerEntityId = dbo.GetVehicleIdFromInt(tev.VehicleIntId) OR tenl.TriggerEntityId = dbo.GetDriverIdFromInt(tev.DriverIntId))
 
	WHERE tev.ProcessInd IN (1, 2) -- New or in delay
	
	-- Entity Selection Parameter Values used below are:
	--	0:	Exclude all entities for the customer (not used for vehicles)
	--	1:	(default) Include all entities for the customer
	--	2:	Include only selected entities
	--	3:	Exclude selected entities
	--  4:  Ignore entity selection - any entity can trigger (not used for vehicles)
	
	-- Identify the Vehicles to be used or excluded in the trigger
	AND 1 = CASE ISNULL(tpv.TriggerParamTypeValue, 1)  
				WHEN 1 THEN 
					CASE WHEN tev.VehicleIntId IS NULL 
						THEN 1 
						ELSE (SELECT 1 WHERE tev.VehicleIntId IN 
									   (SELECT dbo.GetVehicleIntFromId(gd.EntityDataId) 
										FROM dbo.UserGroup ug
										INNER JOIN dbo.GroupDetail gd ON gd.GroupId = ug.GroupId
										INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId AND g.Archived = 0 AND g.IsParameter = 0 AND g.GroupTypeId = 1
										INNER JOIN dbo.[User] u ON u.UserID = ug.UserId AND t.CreatedBy = u.UserID 
										WHERE dbo.GetVehicleIdFromInt(tev.VehicleIntId) = gd.EntityDataId AND gd.GroupTypeId = 1))
					END
				WHEN 2 THEN 
					(SELECT 1 WHERE dbo.GetVehicleIdFromInt(tev.VehicleIntId) IN 
									   (SELECT ten.TriggerEntityId 
										FROM dbo.TAN_TriggerEntity ten
										WHERE ten.TriggerId = t.TriggerId AND ten.Disabled = 0 AND ten.Archived = 0
										  AND ten.TriggerEntityId = dbo.GetVehicleIdFromInt(tev.VehicleIntId)))
 				WHEN 3 THEN 
 					(SELECT 1 WHERE dbo.GetVehicleIdFromInt(tev.VehicleIntId) NOT IN 
 									   (SELECT ten.TriggerEntityId 
 									    FROM dbo.TAN_TriggerEntity ten
										WHERE ten.TriggerId = t.TriggerId AND ten.Disabled = 0 AND ten.Archived = 0
										  AND ten.TriggerEntityId = dbo.GetVehicleIdFromInt(tev.VehicleIntId))
							    AND tev.VehicleIntId IN -- ensure selecting against only the relevant customer
									   (SELECT dbo.GetVehicleIntFromId(cv.VehicleId) 
										FROM dbo.CustomerVehicle cv
										INNER JOIN dbo.[User] u ON cv.CustomerId = u.CustomerID AND t.CreatedBy = u.UserID 
										WHERE dbo.GetVehicleIdFromInt(tev.VehicleIntId) = cv.VehicleId 
										AND dbo.GetCustomerIdFromInt(tev.CustomerIntId) = cv.CustomerId AND cv.Archived = 0 AND cv.EndDate IS NULL))
				WHEN 4 THEN
					(SELECT 1 WHERE ISNULL(tpv.TriggerId, t.TriggerId) = t.TriggerId)
			END -- CASE

	-- Identify the Drivers to be used or excluded in the trigger													  
	AND 1 = CASE ISNULL(tpd.TriggerParamTypeValue, 4)  
				WHEN 0 THEN	
					(SELECT 1 WHERE ISNULL(tev.DriverIntId, 0) NOT IN 
									   (SELECT dbo.GetDriverIntFromId(cd.DriverId) 
									    FROM dbo.CustomerDriver cd
									    INNER JOIN dbo.[User] u ON cd.CustomerId = u.CustomerID AND t.CreatedBy = u.UserID
										WHERE tev.DriverIntId = dbo.GetDriverIntFromId(cd.DriverId) 
										AND tev.CustomerIntId = dbo.GetCustomerIntFromId(cd.CustomerId) AND cd.Archived = 0 AND cd.EndDate IS NULL))
				WHEN 1 THEN 
					CASE WHEN tev.DriverIntId IS NULL 
						THEN 1 
						ELSE (SELECT 1 WHERE tev.DriverIntId IN 
									   (SELECT dbo.GetDriverIntFromId(cd.DriverId) 
									    FROM dbo.CustomerDriver cd
									    INNER JOIN dbo.[User] u ON cd.CustomerId = u.CustomerID AND t.CreatedBy = u.UserID
										WHERE tev.DriverIntId = dbo.GetDriverIntFromId(cd.DriverId) 
										AND tev.CustomerIntId = dbo.GetCustomerIntFromId(cd.CustomerId) AND cd.Archived = 0 AND cd.EndDate IS NULL))
					END
				WHEN 2 THEN 
					(SELECT 1 WHERE dbo.GetDriverIdFromInt(tev.DriverIntId) IN (SELECT ten.TriggerEntityId FROM dbo.TAN_TriggerEntity ten
										WHERE ten.TriggerId = t.TriggerId AND ten.Disabled = 0 AND ten.Archived = 0
										  AND ten.TriggerEntityId = dbo.GetDriverIdFromInt(tev.DriverIntId)))
 				WHEN 3 THEN 
 					(SELECT 1 WHERE dbo.GetDriverIdFromInt(tev.DriverIntId) NOT IN (SELECT ten.TriggerEntityId FROM dbo.TAN_TriggerEntity ten
										WHERE ten.TriggerId = t.TriggerId AND ten.Disabled = 0 AND ten.Archived = 0
										  AND ten.TriggerEntityId = dbo.GetDriverIdFromInt(tev.DriverIntId)))	
				WHEN 4 THEN
					(SELECT 1 WHERE ISNULL(tpd.TriggerId, t.TriggerId) = t.TriggerId)
			END -- CASE
			
	-- Identify the Geofences to be used or excluded in the trigger													  
	AND 1 = CASE ISNULL(tpg.TriggerParamTypeValue, 4)  
				WHEN 0 THEN	
					(SELECT 1 WHERE ISNULL(tev.GeofenceId, NEWID()) NOT IN 
									   (SELECT cg.GeofenceId 
									    FROM dbo.CustomerGeofence cg
									    INNER JOIN dbo.[User] u ON cg.CustomerId = u.CustomerID AND t.CreatedBy = u.UserID
										WHERE tev.GeofenceId = cg.GeofenceId 
										AND tev.CustomerIntId = dbo.GetCustomerIntFromId(cg.CustomerId)))
				WHEN 1 THEN 
					CASE WHEN tev.GeofenceId IS NULL 
						THEN 1 
						ELSE (SELECT 1 WHERE tev.GeofenceId IN 
									   (SELECT cg.GeofenceId 
									    FROM dbo.CustomerGeofence cg
									    INNER JOIN dbo.[User] u ON cg.CustomerId = u.CustomerID AND t.CreatedBy = u.UserID 
										WHERE tev.GeofenceId = cg.GeofenceId 
										AND tev.CustomerIntId = dbo.GetCustomerIntFromId(cg.CustomerId)))
					END
				WHEN 2 THEN 
					(SELECT 1 WHERE tev.GeofenceId IN (SELECT ten.TriggerEntityId FROM dbo.TAN_TriggerEntity ten
										WHERE ten.TriggerId = t.TriggerId AND ten.Disabled = 0 AND ten.Archived = 0
										  AND ten.TriggerEntityId = tev.GeofenceId))
 				WHEN 3 THEN 
 					(SELECT 1 WHERE tev.GeofenceId NOT IN (SELECT ten.TriggerEntityId FROM dbo.TAN_TriggerEntity ten
										WHERE ten.TriggerId = t.TriggerId AND ten.Disabled = 0 AND ten.Archived = 0
										  AND ten.TriggerEntityId = tev.GeofenceId)
								AND tev.GeofenceId IN -- ensure selecting against only the relevant customer
									   (SELECT cg.GeofenceId 
									    FROM dbo.CustomerGeofence cg
									    INNER JOIN dbo.[User] u ON cg.CustomerId = u.CustomerID AND t.CreatedBy = u.UserID 
										WHERE tev.GeofenceId = cg.GeofenceId 
										AND tev.CustomerIntId = dbo.GetCustomerIntFromId(cg.CustomerId)))
				WHEN 4 THEN
					(SELECT 1 WHERE ISNULL(tpg.TriggerId, t.TriggerId) = t.TriggerId)
			END -- CASE

	  -- now select matching start and end times or NULL first start time (indicating no time parameters set)
	  AND (t.TriggerId = tp1.TriggerId AND t.TriggerId = tp2.TriggerId AND CAST(CONVERT(CHAR(8),dbo.TZ_GetTime(tev.TriggerDateTime, NULL, t.CreatedBy),8) AS DateTime) BETWEEN CAST(tp1.TriggerParamTypeValue AS DateTime) AND CAST(tp2.TriggerParamTypeValue + ':59' AS DateTime)
	   OR (t.TriggerId = tp3.TriggerId AND t.TriggerId = tp4.TriggerId AND CAST(CONVERT(CHAR(8),dbo.TZ_GetTime(tev.TriggerDateTime, NULL, t.CreatedBy),8) AS DateTime) BETWEEN CAST(tp3.TriggerParamTypeValue AS DateTime) AND CAST(tp4.TriggerParamTypeValue + ':59' AS DateTime)
	   OR tp1.TriggerId IS NULL)) -- if tp1.TriggerId is NULL there are NO time parameters

	  -- where the 'Act Once' indicator is set check last notify datetime which must be outside the 'current' period
	  AND ((tp5.TriggerId IS NULL OR tp5.TriggerParamTypeValue = '0') -- 'Act Once indicator not set so ignore
	   OR ((DATEPART(dd, dbo.TZ_GetTime(tenl.LatestTriggerDateTime, NULL, t.CreatedBy)) != DATEPART(dd, dbo.TZ_GetTime(GETUTCDATE(), NULL, t.CreatedBy)) OR tenl.LatestTriggerDateTime IS NULL) -- Last alert not today or never alerted before
	   OR  ((CAST(CONVERT(CHAR(8),dbo.TZ_GetTime(tenl.LatestTriggerDateTime, NULL, t.CreatedBy),8) AS DateTime) NOT BETWEEN CAST(tp1.TriggerParamTypeValue AS DateTime) AND CAST(tp2.TriggerParamTypeValue + ':59' AS DateTime) AND CAST(CONVERT(CHAR(8),dbo.TZ_GetTime(tev.TriggerDateTime, NULL, t.CreatedBy),8) AS DateTime) BETWEEN CAST(tp1.TriggerParamTypeValue AS DateTime) AND CAST(tp2.TriggerParamTypeValue + ':59' AS DateTime))
	   OR   (CAST(CONVERT(CHAR(8),dbo.TZ_GetTime(tenl.LatestTriggerDateTime, NULL, t.CreatedBy),8) AS DateTime) NOT BETWEEN CAST(tp3.TriggerParamTypeValue AS DateTime) AND CAST(tp4.TriggerParamTypeValue + ':59' AS DateTime) AND CAST(CONVERT(CHAR(8),dbo.TZ_GetTime(tev.TriggerDateTime, NULL, t.CreatedBy),8) AS DateTime) BETWEEN CAST(tp3.TriggerParamTypeValue AS DateTime) AND CAST(tp4.TriggerParamTypeValue + ':59' AS DateTime)))))

	  -- where a checked out entity is found ensure it is ignored
	  AND ec.EntityId IS NULL
	   
	-- Step 3 -- Insert rows to be notified from @Notify into TAN_NotificationPending
	INSERT INTO TAN_NotificationPending (NotificationId,TriggerId,NotificationTemplateId,RecipientName,VehicleId,DriverId,GeofenceId,ApplicationId,Long,Lat,Heading,Speed,TripDistance,DataName,DataString,DataInt,DataFloat,DataBit,EventId,TriggerDateTime,ProcessInd)
	SELECT	   NEWID(),
			   n.TriggerId,
			   nt.NotificationTemplateId,
			   rn.RecipientName,
			   dbo.GetVehicleIdFromInt(n.VehicleIntId),
			   dbo.GetDriverIdFromInt(n.DriverIntId),
			   n.GeofenceId,
			   n.ApplicationId,
			   n.Long,
			   n.Lat,
			   n.Heading,
			   n.Speed,
			   n.TripDistance,
			   n.DataName,
			   n.DataString,
			   n.DataInt,
			   n.DataFloat,
			   n.DataBit,
			   n.EventId,
			   n.TriggerDateTime,
			   0
	FROM @Notify n
	-- Get the notification templates
	INNER JOIN TAN_NotificationTemplate nt ON n.TriggerId = nt.TriggerId AND nt.Disabled = 0 AND nt.Archived = 0
	---- Get the Recipients for each notification template for the trigger
	LEFT JOIN TAN_RecipientNotification rn ON nt.NotificationTemplateId = rn.NotificationTemplateId AND rn.Disabled = 0 AND rn.Archived = 0
	WHERE ProcessInd = 3 -- Row has matched trigger params and is not in delay

	-- Step 4 -- Update the Process Indicator on the TAN_TriggerEvent table (this ensures records in delay are updated on the source table)
	UPDATE dbo.TAN_TriggerEvent
	SET ProcessInd = CASE WHEN n.ProcessInd IS NULL THEN 5 ELSE n.ProcessInd END	
	FROM dbo.TAN_TriggerEvent tev
	LEFT JOIN @Notify n ON n.TriggerEventId = tev.TriggerEventId
	WHERE tev.ProcessInd IN (1, 2)
	
	-- Step 6 -- Clean Up -- Comment this section out to build up a debugging history
	DELETE 
	FROM dbo.TAN_TriggerEvent
	WHERE ProcessInd IN (3,4,5)
	
END


GO
