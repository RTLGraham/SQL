SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

---- ========================================================================
---- Author:	  Graham Pattison
---- Create date: 07-05-2015
---- Updated:     
---- Description: Loads CAM related data from Gopher into CAM incoming tables
---- ========================================================================
CREATE PROCEDURE [dbo].[proc_PopulateCAMFromGopher]
AS

-- First of all check whether or not this process is still running
-- by trying to create a temprary table
SELECT MyVar = 5 INTO #Populate_CAMIn

IF @@ERROR <> 0
BEGIN
	-- do nothing!
	SELECT 0
END ELSE

BEGIN
	SET NOCOUNT ON;

	DECLARE	@softlock INT,
			@locktime DATETIME

	-- ====================================================================================================================================================
	-- Use softlocking to try and eliminate job failures through deadlocks.
	-- Perform Soft Lock check to ensure Process Cameras is not running before commencing processing. Retry after 5 seconds.
	-- If soft lock has not been released after 90 seconds then attempt processing anyway
	-- ====================================================================================================================================================

	-- Insert row for this process
	INSERT INTO dbo.CAM_SoftLock (ProcessName, LockTime, LockStatus)
	VALUES  ('Populate CAM from Gopher', GETDATE(), 'Waiting')

	SET @softlock = 1
	WHILE ISNULL(@softlock, 0) > 0
	BEGIN
		SELECT @softlock = COUNT(*), @locktime = MAX(LockTime)
		FROM dbo.CAM_SoftLock
		WHERE ProcessName = 'Process Cameras'
		IF ISNULL(@softlock, 0) > 0 WAITFOR DELAY '00:00:05' -- Wait 5 seconds before trying again
		-- Next step is a 'safety' feature. If lock has existed for more than 65 seconds then delete soft lock and try processing anyway
		IF DATEDIFF(ss, @locktime, GETDATE()) > 90 DELETE FROM dbo.CAM_SoftLock WHERE ProcessName = 'Process Cameras'
	END	
	-- Now mark process as running
	UPDATE dbo.CAM_SoftLock SET LockStatus = 'Running' WHERE ProcessName = 'Populate CAM from Gopher'

	-- Have decided to proceed so begin a transaction and use a Try...Catch construct
	--BEGIN TRANSACTION

	--BEGIN TRY

		-- Process Events (for High, Input and Button Event types)
		UPDATE Gopher.dbo.CAM_BulkEventIn
		SET ProcessInd = 1
		FROM Gopher.dbo.CAM_BulkEventIn ei
		INNER JOIN dbo.Camera c ON c.Serial = ei.Serial	
		WHERE ei.ProcessInd is NULL
		  AND ei.EventType IN ('low', 'medium', 'high', 'input1', 'button', 'video_request')
		  AND c.Archived = 0

		INSERT INTO dbo.CAM_EventIn
				( ProjectId,
				  VehicleId,
				  EventDateTime,
				  ApiEventId,
				  EventType,
				  CameraId,
				  Lat,
				  Long,
				  Speed,
				  Heading,
				  LastOperation,
				  Archived
				)
		SELECT  ei.ProjectId,
				vc.VehicleId,
				EventDateTime,
				ApiEventId,
				EventType,
				c.CameraId,
				Lat,
				Long,
				Speed,
				Heading,
				GETDATE(),
				0
		FROM Gopher.dbo.CAM_BulkEventIn ei
		INNER JOIN dbo.Camera c ON c.Serial = ei.Serial
		INNER JOIN dbo.VehicleCamera vc ON c.CameraId = vc.CameraId
		INNER JOIN dbo.Vehicle v ON v.VehicleId = vc.VehicleId
		WHERE ei.ProcessInd = 1
		  AND ei.EventType IN ('low', 'medium', 'high', 'input1', 'button', 'video_request')
		  AND c.Archived = 0
		  AND vc.Archived = 0
		  AND vc.EndDate IS NULL
		  AND v.Archived = 0


		-- Temporary Debug
		--INSERT INTO dbo.CAM_EventIn_DebugTemp
		--		( ProjectId,
		--		  VehicleId,
		--		  EventDateTime,
		--		  ApiEventId,
		--		  EventType,
		--		  CameraId,
		--		  Lat,
		--		  Long,
		--		  Speed,
		--		  Heading,
		--		  LastOperation,
		--		  Archived
		--		)
		--SELECT  ei.ProjectId,
		--		vc.VehicleId,
		--		EventDateTime,
		--		ApiEventId,
		--		EventType,
		--		c.CameraId,
		--		Lat,
		--		Long,
		--		Speed,
		--		Heading,
		--		GETDATE(),
		--		0
		--FROM Gopher.dbo.CAM_BulkEventIn ei
		--INNER JOIN dbo.Camera c ON c.Serial = ei.Serial
		--INNER JOIN dbo.VehicleCamera vc ON c.CameraId = vc.CameraId
		--WHERE ei.ProcessInd = 1
		--  AND ei.EventType IN ('input1', 'button')
		--  AND c.Archived = 0
		--  AND vc.Archived = 0
		--  AND vc.EndDate IS NULL		




		DELETE FROM Gopher.dbo.CAM_BulkEventIn
		FROM Gopher.dbo.CAM_BulkEventIn ei
		INNER JOIN dbo.Camera c ON c.Serial = ei.Serial
		WHERE ei.ProcessInd = 1
		  AND ei.EventType IN ('low', 'medium', 'high', 'input1', 'button', 'video_request')
		  AND c.Archived = 0

		-- Process Events (for all other Event types)
		UPDATE Gopher.dbo.CAM_BulkEventIn
		SET ProcessInd = 1
		FROM Gopher.dbo.CAM_BulkEventIn ei
		INNER JOIN dbo.Camera c ON c.Serial = ei.Serial	
		WHERE ei.ProcessInd is NULL
		  AND ei.EventType NOT IN ('low', 'medium', 'high', 'input1', 'button', 'video_request')
		  AND c.Archived = 0

		INSERT INTO dbo.CAM_Event
				( ProjectId,
				  VehicleId,
				  EventDateTime,
				  ApiEventId,
				  EventType,
				  CameraId,
				  Lat,
				  Long,
				  Speed,
				  Heading,
				  LastOperation,
				  Archived
				)
		SELECT  ei.ProjectId,
				vc.VehicleId,
				EventDateTime,
				ApiEventId,
				EventType,
				c.CameraId,
				Lat,
				Long,
				Speed,
				Heading,
				GETDATE(),
				0
		FROM Gopher.dbo.CAM_BulkEventIn ei
		INNER JOIN dbo.Camera c ON c.Serial = ei.Serial
		INNER JOIN dbo.VehicleCamera vc ON c.CameraId = vc.CameraId
		INNER JOIN dbo.Vehicle v ON v.VehicleId = vc.VehicleId
		WHERE ei.ProcessInd = 1
		  AND ei.EventType NOT IN ('low', 'medium', 'high', 'input1', 'button', 'video_request')
		  AND c.Archived = 0
		  AND vc.Archived = 0
		  AND vc.EndDate IS NULL
		  AND v.Archived = 0

		DELETE FROM Gopher.dbo.CAM_BulkEventIn
		FROM Gopher.dbo.CAM_BulkEventIn ei
		INNER JOIN dbo.Camera c ON c.Serial = ei.Serial
		WHERE ei.ProcessInd = 1	
		  AND ei.EventType NOT IN ('low', 'medium', 'high', 'input1', 'button', 'video_request')
		  AND c.Archived = 0

		-- Process GPS
		UPDATE Gopher.dbo.CAM_BulkGPSIn
		SET ProcessInd = 1
		FROM Gopher.dbo.CAM_BulkGPSIn gi
		INNER JOIN dbo.Camera c ON c.Serial = gi.Serial	
		WHERE gi.ProcessInd is NULL
		  AND c.Archived = 0

		INSERT INTO dbo.CAM_GPSIn
				( ProjectId ,
				  VehicleId ,
				  EventDateTime ,
				  Lat ,
				  Long ,
				  Speed ,
				  Heading ,
				  Distance ,
				  LastOperation ,
				  ProcessInd
				)
		SELECT  gi.ProjectId,
				vc.VehicleId,
				gi.EventDateTime,
				gi.Lat,
				gi.Long,
				gi.Speed,
				gi.Heading,
				gi.Distance,
				GETDATE(),
				0
		FROM Gopher.dbo.CAM_BulkGPSIn gi
		INNER JOIN dbo.Camera c ON c.Serial = gi.Serial
		INNER JOIN dbo.VehicleCamera vc ON c.CameraId = vc.CameraId
		INNER JOIN dbo.Vehicle v ON v.VehicleId = vc.VehicleId
		WHERE gi.ProcessInd = 1
		  AND c.Archived = 0
		  AND vc.Archived = 0
		  AND vc.EndDate IS NULL
		  AND v.IVHId IS NULL
		  AND v.Archived = 0

		DELETE FROM Gopher.dbo.CAM_BulkGPSIn
		FROM Gopher.dbo.CAM_BulkGPSIn gi
		INNER JOIN dbo.Camera c ON c.Serial = gi.Serial
		WHERE gi.ProcessInd = 1
		  AND c.Archived = 0

		-- Process Trips
		UPDATE Gopher.dbo.CAM_BulkTripIn
		SET ProcessInd = 1
		FROM Gopher.dbo.CAM_BulkTripIn ti
		INNER JOIN dbo.Camera c ON c.Serial = ti.Serial	
		WHERE ti.ProcessInd is NULL
		  AND c.Archived = 0

		INSERT INTO dbo.CAM_TripIn
				( ProjectId ,
				  VehicleId ,
				  TripStart ,
				  TripStop ,
				  TripDistance ,
				  LastOperation ,
				  ProcessInd,
				  TripState,
				  TripStartLat,
				  TripStartLon,
				  TripEndLat,
				  TripEndLon
				)
		SELECT  ti.ProjectId,
				vc.VehicleId,
				ti.TripStart,
				ti.TripStop,
				ti.TripDistance,
				GETDATE(),
				0,
				ti.TripState,
				ISNULL(ti.TripStartLat, 0.0),
				ISNULL(ti.TripStartLon, 0.0),
				ISNULL(ti.TripEndLat, 0.0),
				ISNULL(ti.TripEndLon, 0.0)
		FROM Gopher.dbo.CAM_BulkTripIn ti
		INNER JOIN dbo.Camera c ON c.Serial = ti.Serial
		INNER JOIN dbo.VehicleCamera vc ON c.CameraId = vc.CameraId
		INNER JOIN dbo.Vehicle v ON v.VehicleId = vc.VehicleId
		WHERE ti.ProcessInd = 1
		  AND c.Archived = 0
		  AND vc.Archived = 0
		  AND vc.EndDate IS NULL
		  AND v.Archived = 0

		DELETE FROM Gopher.dbo.CAM_BulkTripIn
		FROM Gopher.dbo.CAM_BulkTripIn ti
		INNER JOIN dbo.Camera c ON c.Serial = ti.Serial
		WHERE ti.ProcessInd = 1
		  AND c.Archived = 0

		-- Process Metadata
		UPDATE Gopher.dbo.CAM_BulkMetadataIn
		SET ProcessInd = 1
		FROM Gopher.dbo.CAM_BulkMetadataIn mi
		INNER JOIN dbo.Camera c ON c.Serial = mi.Serial	
		WHERE mi.ProcessInd is NULL
		  AND c.Archived = 0

		INSERT INTO dbo.CAM_MetadataIn
				( CreationCodeId,
				  ApiEventId,
				  ApiMetadataId,
				  LastOperation,
				  Archived,
                  MinX, MaxX,
                  MinY, MaxY,
                  MinZ, MaxZ,
				  ProjectId
				)
		SELECT  CreationCodeId,
				ApiEventId,
				ApiMetadataId,
				GETDATE(),
				0,
                MinX, MaxX,
                MinY, MaxY,
                MinZ, MaxZ,
				mi.ProjectId
		FROM Gopher.dbo.CAM_BulkMetadataIn mi
		INNER JOIN dbo.Camera c ON c.Serial = mi.Serial
		INNER JOIN dbo.VehicleCamera vc ON vc.CameraId = c.CameraId
		INNER JOIN dbo.Vehicle v ON v.VehicleId = vc.VehicleId
		WHERE mi.ProcessInd = 1
		  AND c.Archived = 0
		  AND vc.Archived = 0
		  AND vc.EndDate IS NULL	
		  AND v.Archived = 0

		DELETE FROM Gopher.dbo.CAM_BulkMetadataIn
		FROM Gopher.dbo.CAM_BulkMetadataIn mi
		INNER JOIN dbo.Camera c ON c.Serial = mi.Serial
		WHERE mi.ProcessInd = 1
		  AND c.Archived = 0

		-- Process Videos
		UPDATE Gopher.dbo.CAM_BulkVideoIn
		SET ProcessInd = 1
		FROM Gopher.dbo.CAM_BulkVideoIn vi
		INNER JOIN dbo.Camera c ON c.Serial = vi.Serial	
		WHERE vi.ProcessInd is NULL
		  AND c.Archived = 0

		INSERT INTO dbo.CAM_VideoIn
				( ApiEventId,
				  ApiVideoId,
				  ApiFileName,
				  ApiStartTime,
				  ApiEndTime,
				  CameraNumber,
				  LastOperation,
				  Archived,
				  VideoStatus,
				  ProjectId
				)
		SELECT  ApiEventId,
				ApiVideoId,
				ApiFileName,
				ApiStartTime,
				ApiEndTime,
				CameraNumber,
				GETDATE(),
				0,
				ISNULL(t.VideoStatusTypeId, 0),
				vi.ProjectId
		FROM Gopher.dbo.CAM_BulkVideoIn vi
		LEFT OUTER JOIN dbo.VideoStatusType t ON t.Name = vi.VideoState
		INNER JOIN dbo.Camera c ON c.Serial = vi.Serial
		INNER JOIN dbo.VehicleCamera vc ON vc.CameraId = c.CameraId
		INNER JOIN dbo.Vehicle v ON v.VehicleId = vc.VehicleId
		WHERE vi.ProcessInd = 1
		  AND c.Archived = 0
		  AND vc.Archived = 0
		  AND vc.EndDate IS NULL	
		  AND v.Archived = 0

		DELETE FROM Gopher.dbo.CAM_BulkVideoIn
		FROM Gopher.dbo.CAM_BulkVideoIn vi
		INNER JOIN dbo.Camera c ON c.Serial = vi.Serial
		WHERE vi.ProcessInd = 1
		  AND c.Archived = 0

	--END TRY	
	--BEGIN CATCH

	--INSERT INTO Cloud_App.dbo.Log
	--        ( EventID ,
	--          Priority ,
	--          Severity ,
	--          Title ,
	--          Timestamp ,
	--          MachineName ,
	--          AppDomainName ,
	--          ProcessID ,
	--          ProcessName ,
	--          ThreadName ,
	--          Win32ThreadId ,
	--          Message ,
	--          FormattedMessage
	--        )
	--VALUES  ( 0 , -- EventID - int
	--          1 , -- Priority - int
	--          'Error' , -- Severity - nvarchar(32)
	--          'CAM From Gopher Fail' , -- Title - nvarchar(256)
	--          GETDATE() , -- Timestamp - datetime
	--          HOST_NAME() , -- MachineName - nvarchar(32)
	--          NULL , -- AppDomainName - nvarchar(512)
	--          NULL , -- ProcessID - nvarchar(256)
	--          'Proc_CAMFromGopher' , -- ProcessName - nvarchar(512)
	--          NULL , -- ThreadName - nvarchar(512)
	--          NULL , -- Win32ThreadId - nvarchar(128)
	--          NULL , -- Message - nvarchar(1500)
	--          NULL  -- FormattedMessage - ntext
	--        )

 --   SELECT	ERROR_NUMBER() AS ErrorNumber,
	--		ERROR_SEVERITY() AS ErrorSeverity,
	--		ERROR_STATE() AS ErrorState,
	--		ERROR_PROCEDURE() AS ErrorProcedure,
	--		ERROR_LINE() AS ErrorLine,
	--		ERROR_MESSAGE() AS ErrorMessage

 --   IF @@TRANCOUNT > 0
 --       ROLLBACK TRANSACTION
 --   END CATCH	

	--IF @@TRANCOUNT > 0
	--	COMMIT TRANSACTION

	-- Delete temporary table to indicate job has completed
	DROP TABLE #Populate_CAMIn

	-- Delete soft locking row
	DELETE	
	FROM dbo.CAM_SoftLock
	WHERE ProcessName = 'Populate CAM from Gopher'
END


GO
