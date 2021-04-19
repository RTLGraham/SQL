SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_ChangeVideoDriver]
(
	@evid BIGINT,
	@oldDriverId UNIQUEIDENTIFIER,
	@newDriverId UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER
)
AS

	DECLARE @ccid INT,
			@vintid INT,
			@timestamp DATETIME,
			@olddintid INT,
			@newdintid INT,
			@date DATETIME
	
	-- get the old and new driver int ids
	SET @olddintid = dbo.GetDriverIntFromId(@oldDriverId)
	SET @newdintid = dbo.GetDriverIntFromId(@newDriverId)
		
	-- Get the current data from the Incident to determine what is required for updating ReportingABC		
	SELECT @ccid = CreationCodeId, @vintid = VehicleIntId, @timestamp = EventDateTime
	FROM dbo.CAM_Incident
	WHERE IncidentId = @evid		
	
	-- Update the Incident with the new driver
	UPDATE dbo.CAM_Incident
	SET DriverIntId = @newdintid
	WHERE IncidentId = @evid

	-- Write a row to the Coaching History to record the change
	INSERT INTO dbo.VideoCoachingHistory
	        ( IncidentId ,
	          StatusUserId ,
	          StatusDateTime ,
	          Comments ,
	          LastOperation ,
	          Archived
	        )
	SELECT @evid, @uid, GETUTCDATE(), 'Driver updated for Incident to: ' + dbo.FormatDriverNameByUser(@newDriverId, @uid), GETDATE(), 0
	FROM dbo.Driver
	WHERE DriverId = @newDriverId

	-- Convert timestamp to a date
	SET @date = CAST(FLOOR(CAST(@timestamp AS FLOAT)) AS DATETIME)

	--check if there are rows to update for the new driver
	DECLARE @cnt INT
	SELECT @cnt = COUNT(*)
	FROM dbo.ReportingABC
	WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @newdintid	
	
	IF ISNULL(@cnt,0) = 0
	BEGIN
		INSERT INTO dbo.ReportingABC( VehicleIntId ,DriverIntId ,Acceleration ,Braking ,Cornering ,Date ,AccelerationLow ,BrakingLow ,CorneringLow ,AccelerationHigh ,BrakingHigh ,CorneringHigh)
		VALUES  ( @vintid , -- VehicleIntId - int
		          @newdintid , -- DriverIntId - int
		          0 , -- Acceleration - int
		          0 , -- Braking - int
		          0 , -- Cornering - int
		          @date , -- Date - smalldatetime
		          0 , -- AccelerationLow - int
		          0 , -- BrakingLow - int
		          0 , -- CorneringLow - int
		          0 , -- AccelerationHigh - int
		          0 , -- BrakingHigh - int
		          0  -- CorneringHigh - int
		        )
	END

	-- Now update the old driver ReportingABC record (decrement the count)
	-- added workaround to prevent counts going negative
	IF @ccid = 36 UPDATE dbo.ReportingABC SET Braking = CASE WHEN Braking > 0 THEN ISNULL(Braking, 0) - 1 ELSE 0 END WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @olddintid	
	IF @ccid IN (37,458) UPDATE dbo.ReportingABC SET Acceleration = CASE WHEN Acceleration > 0 THEN ISNULL(Acceleration, 0) - 1 ELSE 0 END WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @olddintid	
	IF @ccid = 38 UPDATE dbo.ReportingABC SET Cornering = CASE WHEN Cornering > 0 THEN ISNULL(Cornering, 0) - 1 ELSE 0 END WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @olddintid	
	IF @ccid = 336 UPDATE dbo.ReportingABC SET BrakingLow = CASE WHEN BrakingLow > 0 THEN ISNULL(BrakingLow, 0) - 1 ELSE 0 END WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @olddintid	
	IF @ccid IN (337,457) UPDATE dbo.ReportingABC SET AccelerationLow = CASE WHEN AccelerationLow > 0 THEN ISNULL(AccelerationLow, 0) - 1 ELSE 0 END WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @olddintid	
	IF @ccid = 338 UPDATE dbo.ReportingABC SET CorneringLow = CASE WHEN CorneringLow > 0 THEN ISNULL(CorneringLow, 0) - 1 ELSE 0 END WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @olddintid	
	IF @ccid = 436 UPDATE dbo.ReportingABC SET BrakingHigh = CASE WHEN BrakingHigh > 0 THEN ISNULL(BrakingHigh, 0) - 1 ELSE 0 END WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @olddintid	
	IF @ccid = 437 UPDATE dbo.ReportingABC SET AccelerationHigh = CASE WHEN AccelerationHigh > 0 THEN ISNULL(AccelerationHigh, 0) - 1 ELSE 0 END WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @olddintid	
	IF @ccid = 438 UPDATE dbo.ReportingABC SET CorneringHigh = CASE WHEN CorneringHigh > 0 THEN ISNULL(CorneringHigh, 0) - 1 ELSE 0 END WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @olddintid	


	-- Now update the new driver ReportingABC record (increment the count)
	IF @ccid = 36 UPDATE dbo.ReportingABC SET Braking = ISNULL(Braking, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @newdintid	
	IF @ccid IN (37,458) UPDATE dbo.ReportingABC SET Acceleration = ISNULL(Acceleration, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @newdintid	
	IF @ccid = 38 UPDATE dbo.ReportingABC SET Cornering = ISNULL(Cornering, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @newdintid	
	IF @ccid = 336 UPDATE dbo.ReportingABC SET BrakingLow = ISNULL(BrakingLow, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @newdintid	
	IF @ccid IN (337,457) UPDATE dbo.ReportingABC SET AccelerationLow = ISNULL(AccelerationLow, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @newdintid	
	IF @ccid = 338 UPDATE dbo.ReportingABC SET CorneringLow = ISNULL(CorneringLow, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @newdintid	
	IF @ccid = 436 UPDATE dbo.ReportingABC SET BrakingHigh = ISNULL(BrakingHigh, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @newdintid	
	IF @ccid = 437 UPDATE dbo.ReportingABC SET AccelerationHigh = ISNULL(AccelerationHigh, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @newdintid	
	IF @ccid = 438 UPDATE dbo.ReportingABC SET CorneringHigh = ISNULL(CorneringHigh, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @newdintid	


GO
