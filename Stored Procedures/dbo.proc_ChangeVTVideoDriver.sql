SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ChangeVTVideoDriver]
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
	FROM dbo.VT_CAM_Incident
	WHERE IncidentId = @evid		
	
	-- Update the Incident with the new driver
	UPDATE dbo.VT_CAM_Incident
	SET DriverIntId = @newdintid
	WHERE IncidentId = @evid

GO
