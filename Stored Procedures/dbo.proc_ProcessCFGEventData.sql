SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ProcessCFGEventData] 
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @vehicleId UNIQUEIDENTIFIER,
			@EventDataName VARCHAR(30),
			@EventDataString VARCHAR(1024)
	
	DECLARE @ConfigData TABLE 
	(
		VehicleId UNIQUEIDENTIFIER,
		Version VARCHAR(12),
		Website VARCHAR(3),
		Network VARCHAR(3),
		Com1 VARCHAR(3),
		Com2 VARCHAR(3),
		CanType VARCHAR(3), 
		Options VARCHAR(26), 
		TestVersion VARCHAR(32)
	)

	-- Mark all relevant rows in EDC
	UPDATE EventDataVehicleFirmware
	SET Archived = 1

	-- First process the CFG rows
	-----------------------------

	DECLARE EDVFCursor CURSOR FAST_FORWARD READ_ONLY
	FOR 
		SELECT VehicleId, EventdataName, EventDataString
		FROM 
			(SELECT v.VehicleId, EventDataName, EventDataString, ROW_NUMBER() OVER (PARTITION BY VehicleId, EventDataName ORDER BY EventDataId DESC) AS RowNum
			FROM dbo.EventDataVehicleFirmware edvf
			INNER JOIN dbo.Vehicle v ON edvf.VehicleIntId = v.VehicleIntId
			WHERE edvf.Archived = 1 AND v.Archived = 0
			  AND edvf.EventDataName = 'CFG') result
		WHERE Result.RowNum = 1	-- select only the latest config for a particular eventdataname					
		
	OPEN EDVFCursor
	FETCH NEXT FROM EDVFCursor INTO @VehicleId, @EventDataName, @EventDataString
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		-- Populate the table for all config data received
		INSERT INTO @ConfigData (VehicleId, Version, Website, Network, Com1, Com2, CanType, Options, TestVersion)	        
		SELECT @VehicleId, Version, Website, Network, Com1, Com2, CanType, Options, TestVersion
		FROM dbo.ParseCFGString(@EventDataString)

		FETCH NEXT FROM EDVFCursor INTO @VehicleId, @EventDataName, @EventDataString
	END
	CLOSE EDVFCursor
	DEALLOCATE EDVFCursor	
	
	-- Insert any new 'Base' Firmware rows
	INSERT INTO dbo.VehicleFirmware (VehicleId, BaseActiveInd, Version, Website, WebsiteChangeInd, Network, NetworkChangeInd, Com1, Com1ChangeInd, Com2, Com2ChangeInd, CanType, CanTypeChangeInd, Options, OptionsChangeInd, TestVersion, LastUpdate)
	SELECT cd.VehicleId,
			'B',
	        cd.Version,
	        cd.Website,
	        0,
	        cd.Network,
	        0,
	        cd.Com1,
	        0,
	        cd.Com2,
	        0,
	        cd.CanType,
	        0,
	        cd.Options,
	        0,
	        cd.TestVersion,
			GETDATE()
	FROM @ConfigData cd
	LEFT JOIN dbo.VehicleFirmware vf ON cd.VehicleId = vf.VehicleId AND vf.BaseActiveInd = 'B'
	WHERE vf.VehicleId IS NULL
 
	-- Insert any new 'Active' Firmware rows
	INSERT INTO dbo.VehicleFirmware (VehicleId, BaseActiveInd, Version, Website, WebsiteChangeInd, Network, NetworkChangeInd, Com1, Com1ChangeInd, Com2, Com2ChangeInd, CanType, CanTypeChangeInd, Options, OptionsChangeInd, TestVersion, LastUpdate)
	SELECT cd.VehicleId,
			'A',
	        cd.Version,
	        cd.Website,
	        0,
	        cd.Network,
	        0,
	        cd.Com1,
	        0,
	        cd.Com2,
	        0,
	        cd.CanType,
	        0,
	        cd.Options,
	        0,
	        cd.TestVersion,
			GETDATE()
	FROM @ConfigData cd
	LEFT JOIN dbo.VehicleFirmware vf ON cd.VehicleId = vf.VehicleId AND vf.BaseActiveInd = 'A'
	WHERE vf.VehicleId IS NULL

	-- Update any 'Active' Firmware rows to match the new config ONLY if the 'Base' has changed
	-- Do this BEFORE updating the 'Base' otherwise we lose the ability to spot the change
	UPDATE dbo.VehicleFirmware
	SET Version = cd.Version,
		Website = cd.Website,
		WebsiteChangeInd = 0,
	    Network = cd.Network,
	    NetworkChangeInd = 0,
	    Com1 = cd.Com1,
	    Com1ChangeInd = 0,
	    Com2 = cd.Com2,
	    Com2ChangeInd = 0,
	    CanType = cd.CanType,
	    CanTypeChangeInd = 0,
	    Options = cd.Options,
	    OptionsChangeInd = 0,
	    TestVersion =  cd.TestVersion,
		LastUpdate = GETDATE()
	FROM @ConfigData cd
	INNER JOIN dbo.VehicleFirmware ON cd.VehicleId = dbo.VehicleFirmware.VehicleId AND dbo.VehicleFirmware.BaseActiveInd = 'A'
	INNER JOIN dbo.VehicleFirmware vfb ON cd.VehicleId = vfb.VehicleId AND vfb.BaseActiveInd = 'B'
	WHERE vfb.Version != cd.Version
	   OR vfb.Website != cd.Website
	   OR vfb.Network != cd.Network
	   OR vfb.Com1 != cd.Com1
	   OR vfb.Com2 != cd.Com2
	   OR vfb.CanType != cd.CanType
	   OR ISNULL(vfb.Options, 'X') != ISNULL(cd.Options, 'X')
	   OR ISNULL(vfb.TestVersion, 'X') != ISNULL(cd.TestVersion, 'X')

	-- Update any 'Base' Firmware rows that have changed (the change indicators are still 0 as they only apply to the Active config)
	UPDATE dbo.VehicleFirmware
	SET Version = cd.Version,
		Website = cd.Website,
		WebsiteChangeInd = 0,
	    Network = cd.Network,
	    NetworkChangeInd = 0,
	    Com1 = cd.Com1,
	    Com1ChangeInd = 0,
	    Com2 = cd.Com2,
	    Com2ChangeInd = 0,
	    CanType = cd.CanType,
	    CanTypeChangeInd = 0,
	    Options = cd.Options,
	    OptionsChangeInd = 0,
	    TestVersion =  cd.TestVersion,
		LastUpdate = GETDATE()
	FROM @ConfigData cd
	INNER JOIN dbo.VehicleFirmware vf ON cd.VehicleId = vf.VehicleId AND vf.BaseActiveInd = 'B'
	WHERE vf.Version != cd.Version
	   OR vf.Website != cd.Website
	   OR vf.Network != cd.Network
	   OR vf.Com1 != cd.Com1
	   OR vf.Com2 != cd.Com2
	   OR vf.CanType != cd.CanType
	   OR ISNULL(vf.Options, 'X') != ISNULL(cd.Options, 'X')
	   OR ISNULL(vf.TestVersion, 'X') != ISNULL(cd.TestVersion, 'X')

	-- Now process all other rows
	-----------------------------
	
	DELETE
	FROM @ConfigData

	DECLARE EDVFCursor CURSOR FAST_FORWARD READ_ONLY
	FOR 
		SELECT VehicleId, EventdataName, EventDataString
		FROM 
			(SELECT v.VehicleId, EventDataName, EventDataString, ROW_NUMBER() OVER (PARTITION BY VehicleId, EventDataName ORDER BY EventDataId DESC) AS RowNum
			FROM dbo.EventDataVehicleFirmware edvf
			INNER JOIN dbo.Vehicle v ON edvf.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
			WHERE edvf.Archived = 1 AND v.Archived = 0
			  AND i.IVHTypeId = 5 -- only parse for Cheetah devices as firmware handled differently for other devices
			  AND edvf.EventDataName != 'CFG') result
		WHERE Result.RowNum = 1	-- select only the latest config for a particular eventdataname	
	
	OPEN EDVFCursor
	FETCH NEXT FROM EDVFCursor INTO @VehicleId, @EventDataName, @EventDataString
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		-- Populate the table for all config data received
		IF @EventDataName = '+RTLF:'
		BEGIN
			INSERT INTO @ConfigData (VehicleId, Com1, Com2)	        
			SELECT @VehicleId, Com1, Com2
			FROM dbo.ParseRTLFString(@eventdatastring)
		END	
		
		IF @EventDataName = '+RTLW:'
		BEGIN
			INSERT INTO @ConfigData (VehicleId, Com1, Com2)	        
			SELECT @VehicleId, Com1, Com2
			FROM dbo.ParseRTLWString(@eventdatastring)
		END	
		
		IF @EventDataName = '+RTLV:'
		BEGIN
			INSERT INTO @ConfigData (VehicleId, Com1, Com2)	        
			SELECT @VehicleId, Com1, Com2
			FROM dbo.ParseRTLVString(@eventdatastring)
		END	
		
		IF @EventDataName = '+RTLK:'
		BEGIN
			INSERT INTO @ConfigData (VehicleId, CanType)	        
			SELECT @VehicleId, Can
			FROM dbo.ParseRTLKString(@eventdatastring)
		END
		
		IF @EventDataName = '+CTCD:'
		BEGIN
			INSERT INTO @ConfigData (VehicleId, Website)	        
			SELECT @VehicleId, Website
			FROM dbo.ParseCTCDString(@eventdatastring)
		END
		
		IF @EventDataName = '+CTCE:'
		BEGIN
			INSERT INTO @ConfigData (VehicleId, Network)	        
			SELECT @VehicleId, Network
			FROM dbo.ParseCTCEString(@eventdatastring)
		END
		
		FETCH NEXT FROM EDVFCursor INTO @VehicleId, @EventDataName, @EventDataString
	END
	CLOSE EDVFCursor
	DEALLOCATE EDVFCursor
	
	-- Apply any changes to the Active Firmware rows
	UPDATE dbo.VehicleFirmware
	SET Version = (CASE WHEN cd.Version IS NOT NULL THEN cd.Version ELSE vf.Version END), 
		Website = (CASE WHEN cd.Website IS NOT NULL THEN cd.Website ELSE vf.Website END),   
	    WebsiteChangeInd = (CASE WHEN cd.Website IS NOT NULL THEN 1 ELSE vf.WebsiteChangeInd END),  
	    Network = (CASE WHEN cd.Network IS NOT NULL THEN cd.Network ELSE vf.Network END),   
	    NetworkChangeInd = (CASE WHEN cd.Network IS NOT NULL THEN 1 ELSE vf.NetworkChangeInd END),
		Com1 = (CASE WHEN cd.Com1 IS NOT NULL THEN cd.Com1 ELSE vf.Com1 END),   
	    Com1ChangeInd = (CASE WHEN cd.Com1 IS NOT NULL THEN 1 ELSE vf.Com1ChangeInd END),    
	    Com2 = (CASE WHEN cd.Com2 IS NOT NULL THEN cd.Com2 ELSE vf.Com2 END), 
	    Com2ChangeInd = (CASE WHEN cd.Com2 IS NOT NULL THEN 1 ELSE vf.Com2ChangeInd END), 
	    CanType = (CASE WHEN cd.CanType IS NOT NULL THEN cd.CanType ELSE vf.CanType END), 
	    CanTypeChangeInd = (CASE WHEN cd.CanType IS NOT NULL THEN 1 ELSE vf.CanTypeChangeInd END),
		LastUpdate = GETDATE()
	FROM @ConfigData cd
	INNER JOIN dbo.VehicleFirmware vf ON cd.VehicleId = vf.VehicleId AND vf.BaseActiveInd = 'A'
	WHERE vf.Version != cd.Version
	   OR vf.Website != cd.Website
	   OR vf.Network != cd.Network
	   OR vf.Com1 != cd.Com1
	   OR vf.Com2 != cd.Com2
	   OR vf.CanType != cd.CanType

	-- Clean up processed rows
	DELETE FROM dbo.EventDataVehicleFirmware
	WHERE archived = 1 

	
END


GO
