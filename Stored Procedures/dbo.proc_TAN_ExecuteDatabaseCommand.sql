SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_TAN_ExecuteDatabaseCommand] 
AS
BEGIN

	SET NOCOUNT ON	

	DECLARE @command VARCHAR(500),
			@vid UNIQUEIDENTIFIER,
			@did UNIQUEIDENTIFIER,
			@geoid UNIQUEIDENTIFIER,
			@uid UNIQUEIDENTIFIER,
			@datetime DATETIME
	
	-- Mark commands ready to process
	UPDATE dbo.TAN_DatabaseCommand
	SET ProcessInd = 1
	WHERE ProcessInd = 0

	-- Cursor round the TAN_DatabaseCommand table and execute any unprocessed stored procedures
	DECLARE CommandCursor CURSOR FAST_FORWARD
	FOR
	SELECT Command, VehicleId, DriverId, GeofenceId, UserId, TriggerDateTime
	FROM dbo.TAN_DatabaseCommand
	WHERE ProcessInd = 1

	OPEN CommandCursor
	FETCH NEXT FROM CommandCursor INTO @command, @vid, @did, @geoid, @uid, @datetime
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Execute the relevant stored procedure according to the command and use the appropriate parameters
		IF @command = 'NotifyShiftTimeRemaining'
			EXEC proc_TAN_NotifyShiftTimeRemaining @vid, @did, @datetime, @geoid, @uid

		FETCH NEXT FROM CommandCursor INTO @command, @vid, @did, @geoid, @uid, @datetime

	END

	CLOSE CommandCursor
	DEALLOCATE CommandCursor	
		
	-- Delete processed commands
	DELETE	
	FROM dbo.TAN_DatabaseCommand
	WHERE ProcessInd = 1

END






GO
