SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_ChangeEventVideoType]
(
	@eid BIGINT = NULL,
	@evid BIGINT,
	@uid UNIQUEIDENTIFIER,
	@newCreationCode SMALLINT,
	@comment NVARCHAR(MAX)
)
AS	
	UPDATE dbo.CAM_Incident
	SET CreationCodeId = @newCreationCode
	WHERE IncidentId = @evid
	
	IF @eid IS NOT NULL AND @eid != 0
	BEGIN
		UPDATE dbo.Event
		SET CreationCodeId = @newCreationCode
		WHERE EventId = @eid
	END

	DECLARE @oldcc SMALLINT,
			@coachingStatus INT,
			@vintid INT,
			@dintid INT,
			@timestamp DATETIME,
			@date DATETIME
		
	-- Get the old status, creation code, vehicle, driver and date to determine what is required for updating ReportingABC		
	SELECT @coachingStatus = CoachingStatusId, @oldcc = CreationCodeId, @vintid = VehicleIntId, @dintid = DriverIntId, @date = CAST(FLOOR(CAST(EventDateTime AS FLOAT)) AS DATETIME)
	FROM dbo.CAM_Incident
	WHERE IncidentId = @evid	

	--if the old creation code was 0 and video was already passed to coaching (by analyst or automatically) - we need to update the corresponding ReportingABC value
	IF (@oldcc IS NOT NULL AND @oldcc = 0 AND @newCreationCode != 0 AND @vintid IS NOT NULL AND @dintid IS NOT NULL AND @date IS NOT NULL 
		AND @coachingStatus IS NOT NULL AND @coachingStatus IN (1,2,3,4))
	BEGIN
		--check if there are rows to update
		DECLARE @cnt INT
		SELECT @cnt = COUNT(*)
		FROM dbo.ReportingABC
		WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
	
		IF ISNULL(@cnt,0) = 0
		BEGIN
			INSERT INTO dbo.ReportingABC( VehicleIntId ,DriverIntId ,Acceleration ,Braking ,Cornering ,Date ,AccelerationLow ,BrakingLow ,CorneringLow ,AccelerationHigh ,BrakingHigh ,CorneringHigh)
			VALUES  ( @vintid , -- VehicleIntId - int
					  @dintid , -- DriverIntId - int
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

		IF @newCreationCode = 36 UPDATE dbo.ReportingABC SET Braking = ISNULL(Braking, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @newCreationCode IN (37,458) UPDATE dbo.ReportingABC SET Acceleration = ISNULL(Acceleration, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @newCreationCode = 38 UPDATE dbo.ReportingABC SET Cornering = ISNULL(Cornering, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @newCreationCode = 336 UPDATE dbo.ReportingABC SET BrakingLow = ISNULL(BrakingLow, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @newCreationCode IN (337,457) UPDATE dbo.ReportingABC SET AccelerationLow = ISNULL(AccelerationLow, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @newCreationCode = 338 UPDATE dbo.ReportingABC SET CorneringLow = ISNULL(CorneringLow, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @newCreationCode = 436 UPDATE dbo.ReportingABC SET BrakingHigh = ISNULL(BrakingHigh, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @newCreationCode = 437 UPDATE dbo.ReportingABC SET AccelerationHigh = ISNULL(AccelerationHigh, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
		IF @newCreationCode = 438 UPDATE dbo.ReportingABC SET CorneringHigh = ISNULL(CorneringHigh, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
	END

GO
