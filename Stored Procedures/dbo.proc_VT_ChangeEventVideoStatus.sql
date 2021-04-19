SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_VT_ChangeEventVideoStatus]
(
	@evid BIGINT,
	@uid UNIQUEIDENTIFIER = NULL,
	@newStatus INT = NULL,
	@comment NVARCHAR(MAX) = NULL,
	@ccid INT = NULL	
)
AS

/********************************************************************************/
/* This stored procedure is used to update Reporting and generate TAN and Push  */ 
/* Called from DataDispatcher MonitoringServiceVTNewData module                 */
/********************************************************************************/

	DECLARE @oldStatus INT,
			@oldCcid INT,
			@vintid INT,
			@dintid INT,
			@timestamp DATETIME,
			@date DATETIME,
			@umnId UNIQUEIDENTIFIER,
			@customerIntId INT
		
	-- Get the old status, creation code, vehicle, driver and date to determine what is required for updating ReportingABC		
	SELECT	@oldStatus = CoachingStatusId, @oldCcid = CreationCodeId, @vintid = VehicleIntId, @dintid = DriverIntId, @timestamp = EventDateTime,
			@customerIntId = CustomerIntId
	FROM dbo.VT_CAM_Incident
	WHERE IncidentId = @evid	
	
	IF @ccid IS NULL -- The CCid has NOT been passed in as a parameter, so use the Ccid that was already recorded on the Incident
		SET @ccid = @oldCcid	
	
	
	/* 1. Register the Trigger event */
	INSERT INTO dbo.TAN_TriggerEvent (TriggerEventId, CreationCodeId, EventId, CustomerIntId, VehicleIntID, DriverIntId, ApplicationId, Long, Lat, Heading, Speed, TriggerDateTime, ProcessInd, LastOperation)
	SELECT NEWID(), 138, i.EventId, i.CustomerIntId, i.VehicleIntId, i.DriverIntId, 9, i.Long, i.Lat, i.Heading, i.Speed, i.EventDateTime, 0, GETDATE()
	FROM dbo.VT_CAM_Incident i 
	WHERE i.IncidentId = @evid

	/* 2. Update reporting */

	-- Convert timestamp to a date
	SET @date = CAST(FLOOR(CAST(@timestamp AS FLOAT)) AS DATETIME)

	--check if there are rows to update
	DECLARE @cnt INT
	SELECT @cnt = COUNT(*)
	FROM dbo.ReportingABC
	WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
	
	IF ISNULL(@cnt,0) = 0
	BEGIN
		INSERT INTO dbo.ReportingABC( VehicleIntId ,DriverIntId ,Acceleration ,Braking ,Cornering ,Date ,AccelerationLow ,BrakingLow ,CorneringLow ,AccelerationHigh ,BrakingHigh ,CorneringHigh)
		VALUES  (@vintid, @dintid, 0, 0, 0, @date, 0, 0, 0, 0, 0, 0)
	END

	-- Now determine any required updates to ReportingABC
	IF @ccid = 436 UPDATE dbo.ReportingABC SET BrakingHigh = ISNULL(BrakingHigh, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
	IF @ccid = 437 UPDATE dbo.ReportingABC SET AccelerationHigh = ISNULL(AccelerationHigh, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	
	IF @ccid = 438 UPDATE dbo.ReportingABC SET CorneringHigh = ISNULL(CorneringHigh, 0) + 1 WHERE Date = @date AND VehicleIntId = @vintid AND DriverIntId = @dintid	


GO
