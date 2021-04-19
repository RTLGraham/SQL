SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_DeleteMaintenanceFault]
(
       @faultId INT
)
AS
    --DECLARE @faultId INT
    --SET @faultId = 8

	DECLARE @jobId INT,
			@vehicleId UNIQUEIDENTIFIER,
			@faultTypeId SMALLINT,
			@faultType VARCHAR(100)

	-- Get MaintenanceJobId, VehicleId and FaultType for later
	SELECT @jobId = mf.MaintenanceJobId, @vehicleId = v.VehicleId, @faultTypeId = mf.FaultTypeId, @faultType = mft.Name + ' (' + mft.Description + ')'
	FROM dbo.MaintenanceFault mf
	INNER JOIN dbo.MaintenanceFaultType mft ON mft.FaultTypeId = mf.FaultTypeId
	INNER JOIN dbo.MaintenanceJob mj ON mj.MaintenanceJobId = mf.MaintenanceJobId
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = mj.VehicleIntId
	WHERE mf.MaintenanceFaultId = @faultId

	-- Add a note for the vehicle to record that Maintenance Item has been auto-removed
	INSERT INTO dbo.Note
	        ( NoteId ,
	          NoteEntityId ,
	          NoteTypeId ,
	          Note ,
	          NoteDate ,
	          LastModified ,
	          Archived
	        )
	VALUES  ( NEWID() , -- NoteId - uniqueidentifier
	          @vehicleId , -- NoteEntityId - uniqueidentifier
	          2 , -- NoteTypeId - int
	          'Maintenance Fault Type ' + CAST(@faultTypeId AS VARCHAR(3)) + ' : ' + @faultType + ' has been automatically removed from Proactive Maintenance. Fault no longer occurs.' ,-- Note - nvarchar(max)
	          GETDATE() , -- NoteDate - datetime
	          GETDATE() , -- LastModified - datetime
	          0  -- Archived - bit
	        )

	DELETE FROM dbo.MaintenanceFault
	WHERE MaintenanceFaultId = @faultId 

	-- If this has resulted in an orphaned MaintenanceJob then delete it
	DELETE FROM dbo.MaintenanceJob
	FROM dbo.MaintenanceJob mj
	LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId
	WHERE mj.MaintenanceJobId = @jobId
	  AND mf.MaintenanceFaultId IS NULL	


GO
