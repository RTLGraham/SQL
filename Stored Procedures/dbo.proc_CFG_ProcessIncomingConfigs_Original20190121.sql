SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_CFG_ProcessIncomingConfigs_Original20190121] 
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @vehicleIntId INT,
			@EventDataName VARCHAR(30),
			@EventDataString VARCHAR(1024)
	
	DECLARE @ConfigData TABLE (
			IVHIntId INT,
			KeyId INT,
			KeyValue NVARCHAR(MAX)
	)

	-- Mark all relevant rows in EDC
	UPDATE EventDataCopy 
	SET Archived = 1 
	WHERE EventDataName IN (SELECT DISTINCT EventDataNamePrefix + CommandRoot + EventDatanameSuffix
							FROM dbo.CFG_Command
							INNER JOIN dbo.IVHType ON dbo.CFG_Command.IVHTypeId = dbo.IVHType.IVHTypeId)

	DECLARE EDCCursor CURSOR FAST_FORWARD READ_ONLY
	FOR 
		SELECT VehicleIntId, EventDataName, EventDataString
		FROM 
			(SELECT VehicleIntId, EventDataName, EventDataString, ROW_NUMBER() OVER (PARTITION BY VehicleIntId, EventDataName ORDER BY EventDataId DESC) AS RowNum
			FROM dbo.EventDataCopy
			WHERE Archived = 1 
			  AND EventDataName IN (SELECT DISTINCT EventDataNamePrefix + CommandRoot + EventDatanameSuffix
								FROM dbo.CFG_Command
								INNER JOIN dbo.IVHType ON dbo.CFG_Command.IVHTypeId = dbo.IVHType.IVHTypeId)) result
		WHERE Result.RowNum = 1	-- select only the latest update for a particular command for a vehicle					
		
	OPEN EDCCursor
	FETCH NEXT FROM EDCCursor INTO @VehicleIntId, @EventDataName, @EventDataString
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		-- Populate the table for all config data received
		INSERT INTO @ConfigData
				( IVHIntId, KeyId, KeyValue )
		        
		SELECT IVHIntId, KeyId, KeyValue
		FROM dbo.ParseConfigData(@VehicleIntId, @EventDataName, @EventDataString)

		FETCH NEXT FROM EDCCursor INTO @VehicleIntId, @EventDataName, @EventDataString
	END
	CLOSE EDCCursor
	DEALLOCATE EDCCursor	
	
	-- These are the steps required (some later steps become true or false as a result of actions taken on earlier steps):
	-- We have a key matching an active key and the value is the same --> should leave this row alone to keep integrity of StartDate
	--																		but instruction is to discontinue old key and insert new key! 
	-- We have a key matching a pending key but the value is different --> mark the pending as failed
	-- We have a key matching a pending value and the value matches --> mark the pending as active 
	-- We have a key matching an active key but the value is different --> discontinue old key 
	-- We have no active matching key --> insert new active key

	-- We have a key matching an active key and the value is the same --> discontinue old key and allow new key to be inserted in later step 
	UPDATE dbo.CFG_History
	SET EndDate = GETUTCDATE()
	FROM @ConfigData cd
	INNER JOIN dbo.CFG_History h ON cd.IVHIntId = h.IVHIntId AND cd.KeyId = h.KeyId AND cd.KeyValue = h.KeyValue
	WHERE h.EndDate IS NULL AND h.Status = 1
	
	-- We have a key matching a pending key but the value is different --> mark the pending as failed	
	UPDATE dbo.CFG_History
	SET Status = 0
	FROM @ConfigData cd
	INNER JOIN dbo.CFG_History h ON cd.IVHIntId = h.IVHIntId AND cd.KeyId = h.KeyId AND cd.KeyValue != h.KeyValue
	WHERE h.EndDate IS NULL AND h.Status IS NULL

	-- We have a key matching a pending value and the value matches --> mark the pending as active 	
	UPDATE dbo.CFG_History
	SET Status = 1, StartDate = GETUTCDATE()
	FROM @ConfigData cd
	INNER JOIN dbo.CFG_History h ON cd.IVHIntId = h.IVHIntId AND cd.KeyId = h.KeyId AND cd.KeyValue = h.KeyValue
	WHERE h.EndDate IS NULL AND h.Status IS NULL

	-- We have a key matching an active key but the value is different --> discontinue old key and allow new key to be inserted in next step
	UPDATE dbo.CFG_History
	SET EndDate = GETUTCDATE()
	FROM @ConfigData cd
	INNER JOIN dbo.CFG_History h ON cd.IVHIntId = h.IVHIntId AND cd.KeyId = h.KeyId AND cd.KeyValue != h.KeyValue
	WHERE h.EndDate IS NULL AND h.Status = 1
	
	-- We have no active matching key --> insert new active key
	INSERT INTO dbo.CFG_History (IVHIntId, KeyId, KeyValue, StartDate, EndDate, Status, LastOperation)
	SELECT cd.IVHIntId, cd.KeyId, cd.KeyValue, GETUTCDATE(), NULL, 1, GETDATE()
	FROM @ConfigData cd
	WHERE NOT EXISTS (SELECT 1
					  FROM dbo.CFG_History h
					  WHERE cd.IVHIntId = h.IVHIntId
					    AND cd.KeyId = h.KeyId
					    AND h.EndDate IS NULL
					    AND h.Status = 1)

	DELETE FROM dbo.EventDataCopy 
	WHERE archived = 1 
	  AND EventDataName IN (SELECT DISTINCT EventDataNamePrefix + CommandRoot + EventDatanameSuffix
							FROM dbo.CFG_Command
							INNER JOIN dbo.IVHType ON dbo.CFG_Command.IVHTypeId = dbo.IVHType.IVHTypeId)
	
END
GO
