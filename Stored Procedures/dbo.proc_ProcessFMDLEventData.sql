SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ProcessFMDLEventData] 
AS
BEGIN

	/********************************************************************************************************************************/
	/*	Process EventDataFMDL according to the following creation codes:															*/
	/*	102	-	FT_File segment transfer has completed successfully - initiate the next segment or mark whole transfer as complete	*/
	/*	103	-	Information only - device file manager is re-attempting transfer to attached device									*/
	/*	106	-	Information only - file has successfully been transferred to device													*/
	/*	107	-	Information only - device will re-attempt to download file from server												*/
	/*	401	-	File download from server failed - re-issue file transfer command													*/
	/********************************************************************************************************************************/

	SET NOCOUNT ON;

	DECLARE @vehicleIntId INT,
			@creationCodeId SMALLINT,
			@eventDataName VARCHAR(20),
			@EventDataString VARCHAR(1024),
			@commandString VARCHAR(1024),
			@ivhId UNIQUEIDENTIFIER,
			@FT_FileId INT,
			@FT_FileSegmentNum SMALLINT,
			@isTransferComplete BIT	

	-- Mark all relevant rows in EDC
	UPDATE EventDataFMDL
	SET Archived = 1

	-- Process the rows using a cursor
	DECLARE FMDLCursor CURSOR FAST_FORWARD READ_ONLY
	FOR
		SELECT VehicleIntId, CreationCodeId, EventDataName, EventDataString
		FROM dbo.EventDataFMDL
		WHERE Archived = 1
		  AND CreationCodeId IN (102, 401) -- only interested in these creation codes - others are information only

	OPEN FMDLCursor
	FETCH NEXT FROM FMDLCursor INTO @vehicleIntId, @creationCodeId, @eventDataName, @EventDataString

	WHILE @@FETCH_STATUS = 0
	BEGIN	

		-- Get FT_FileId and Segment number for the current filename
		SELECT @FT_FileId = zs.FT_FileId, @FT_FileSegmentNum = zs.SegmentNum
		FROM dbo.Vehicle v
		INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
		INNER JOIN [192.168.53.14].CommServer.dbo.Device d ON d.IMEI = i.TrackerNumber
		INNER JOIN [192.168.53.14].CommServer.dbo.DeviceType dt ON dt.DeviceTypeId = d.DeviceTypeId
		INNER JOIN [192.168.53.14].CommServer.dbo.FileTransfer ft ON ft.DeviceId = d.DeviceId
		INNER JOIN [192.168.53.14].CommServer.dbo.FT_FileSegment zs ON zs.FT_FileId = ft.FT_FileId
		INNER JOIN [192.168.53.14].CommServer.dbo.AttachedDevice ad ON ad.AttachedDeviceId = ft.AttachedDeviceId
		INNER JOIN [192.168.53.14].CommServer.dbo.AttachedDeviceType adt ON adt.AttachedDeviceTypeId = ad.AttachedDeviceTypeId AND adt.ProjectCode = @eventDataName
		INNER JOIN [192.168.53.14].CommServer.dbo.Command c ON c.CommandRoot = 'FMDL' AND c.DeviceTypeId = dt.DeviceTypeId -- File transfer command for this device type
		WHERE zs.Url = @EventDataString
		  AND v.VehicleIntId = @vehicleIntId
		  AND i.Archived = 0
		  AND d.Archived = 0
		  AND dt.Archived = 0
		  AND adt.Archived = 0

		-- Determine the command for the next segment (or a retry) - if we are already finished this will generate NULL
		SELECT @commandString = dt.WriteCommandPrefix + c.PromoteInd + c.CommandRoot + dt.WriteCommandSuffix + zs.Url 
				+ ',a:/fileMan/peripheralout/,'
				+ adt.ProjectCode + ',0,2', @ivhId = i.IVHId
		FROM dbo.Vehicle v
		INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
		INNER JOIN [192.168.53.14].CommServer.dbo.Device d ON d.IMEI = i.TrackerNumber
		INNER JOIN [192.168.53.14].CommServer.dbo.DeviceType dt ON dt.DeviceTypeId = d.DeviceTypeId
		INNER JOIN [192.168.53.14].CommServer.dbo.FileTransfer ft ON ft.DeviceId = d.DeviceId AND ft.FT_FileId = @FT_FileId
		INNER JOIN [192.168.53.14].CommServer.dbo.AttachedDevice ad ON ad.AttachedDeviceId = ft.AttachedDeviceId
		INNER JOIN [192.168.53.14].CommServer.dbo.AttachedDeviceType adt ON adt.AttachedDeviceTypeId = ad.AttachedDeviceTypeId AND adt.ProjectCode = @eventDataName
		INNER JOIN [192.168.53.14].CommServer.dbo.Command c ON c.CommandRoot = 'FMDL' AND c.DeviceTypeId = dt.DeviceTypeId -- File transfer command for this device type
		CROSS JOIN [192.168.53.14].CommServer.dbo.FT_FileSegment zs
		WHERE zs.FT_FileId = @FT_FileId
		  AND zs.SegmentNum = CASE WHEN @creationCodeId = 102 THEN @FT_FileSegmentNum + 1 ELSE @FT_FileSegmentNum END 
		  AND v.VehicleIntId = @vehicleIntId
		  AND i.Archived = 0
		  AND d.Archived = 0
		  AND dt.Archived = 0
		  AND adt.Archived = 0
		  AND c.Archived = 0

		IF @commandString IS NOT NULL -- we have a command to insert
		BEGIN	
			INSERT INTO dbo.VehicleCommand (IVHId, Command, ExpiryDate, AcknowledgedDate, LastOperation, Archived, ProcessInd, ReceivedDate)
			SELECT @ivhId, CAST(@commandString AS VARBINARY(1024)), DATEADD(DAY, 7, GETDATE()), NULL, GETDATE(), 0, 0, NULL
		END
        
		-- Now update the CompletedSegmentNum on CommServer FileTransfer
		IF @creationCodeId = 102
		BEGIN
        
			UPDATE [192.168.53.14].CommServer.dbo.FileTransfer
			SET CompletedSegmentNum = @FT_FileSegmentNum
			FROM dbo.Vehicle v
			INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
			INNER JOIN [192.168.53.14].CommServer.dbo.Device d ON d.IMEI = i.TrackerNumber
			INNER JOIN [192.168.53.14].CommServer.dbo.FileTransfer ft ON ft.DeviceId = d.DeviceId AND FT_FileId = @FT_FileId
			INNER JOIN [192.168.53.14].CommServer.dbo.AttachedDevice ad ON ad.AttachedDeviceId = ft.AttachedDeviceId
			INNER JOIN [192.168.53.14].CommServer.dbo.AttachedDeviceType adt ON adt.AttachedDeviceTypeId = ad.AttachedDeviceTypeId AND adt.ProjectCode = @eventDataName
			WHERE v.VehicleIntId = @vehicleIntId
			  AND i.Archived = 0
			  AND d.Archived = 0

		END

		-- If we have transferred the final segment update the AppHistory with the InstalledDate and OTAStatus
		SET @isTransferComplete = 0 -- initialise
		SELECT @isTransferComplete = CASE WHEN NumSegments = @FT_FileSegmentNum THEN 1 ELSE 0 END	
		FROM [192.168.53.14].CommServer.dbo.FT_File
		WHERE FT_FileId = @FT_FileId

		IF @isTransferComplete = 1
		BEGIN	

			UPDATE [192.168.53.14].CommServer.dbo.AppHistory
			SET InstalledDate = GETUTCDATE(), OTAStatusId = 3, LastOperation = GETDATE()
			FROM dbo.Vehicle v
			INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
			INNER JOIN [192.168.53.14].CommServer.dbo.Device d ON d.IMEI = i.TrackerNumber
			INNER JOIN [192.168.53.14].CommServer.dbo.FileTransfer ft ON ft.DeviceId = d.DeviceId AND FT_FileId = @FT_FileId
			INNER JOIN [192.168.53.14].CommServer.dbo.AttachedDevice ad ON ad.AttachedDeviceId = ft.AttachedDeviceId
			INNER JOIN [192.168.53.14].CommServer.dbo.AttachedDeviceType adt ON adt.AttachedDeviceTypeId = ad.AttachedDeviceTypeId AND adt.ProjectCode = @eventDataName
			INNER JOIN [192.168.53.14].CommServer.dbo.FT_FileAppComponent zac ON zac.FT_FileId = ft.FT_FileId
			INNER JOIN [192.168.53.14].CommServer.dbo.AppHistory ah ON ah.AppComponentId = zac.AppComponentId AND ah.AttachedDeviceId = ft.AttachedDeviceId
			WHERE v.VehicleIntId = @vehicleIntId
			  AND i.Archived = 0
			  AND d.Archived = 0
			  AND ah.Archived = 0

		END	
        
		FETCH NEXT FROM FMDLCursor INTO @vehicleIntId, @creationCodeId, @eventDataName, @EventDataString

	END	
		
	CLOSE FMDLCursor
	DEALLOCATE FMDLCursor

	-- Clean up processed rows
	DELETE FROM dbo.EventDataFMDL
	WHERE archived = 1 

END




GO
