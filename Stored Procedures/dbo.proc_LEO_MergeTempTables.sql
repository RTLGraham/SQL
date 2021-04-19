SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =========================================================================================
-- Author:		<Jamie Bartleet>
-- Create date: <26/10/2017>
-- Description:	<Merge temporary Leopard tables into live then delete temp tables' contents>
-- =========================================================================================
CREATE PROCEDURE [dbo].[proc_LEO_MergeTempTables]
AS
BEGIN
	SET NOCOUNT ON;
	

	-- 1. merge configuration settings

	MERGE dbo.LEO_ConfigurationSetting AS TARGET
	USING dbo.LEO_Temp_ConfigurationSetting AS SOURCE 
	ON (TARGET.ApplicationConfigurationFileId = SOURCE.ApplicationConfigurationFileId
	AND TARGET.Name = SOURCE.Name)
 
		--When records are matched, update the records if there is any change
		WHEN MATCHED AND TARGET.Value <> SOURCE.Value THEN 
			UPDATE SET TARGET.Value = SOURCE.Value,
				       TARGET.LastOperation = GetDate(),
					   TARGET.Archived = 0

		--When record is not matched, insert the temp records to live table
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT (ApplicationConfigurationFileId, Name, Value, LastOperation, Archived) 
			VALUES (SOURCE.ApplicationConfigurationFileId, SOURCE.Name, SOURCE.Value, GetDate(), 0)

		--When there is a row that exists in the live table and same record does not exist in temp table then archive  the value in target table
		WHEN NOT MATCHED BY SOURCE THEN 
			--DELETE
			UPDATE SET TARGET.LastOperation = GetDate(),
					   TARGET.Archived = 1

		--OUTPUT $action, 
		--DELETED.ConfigurationSettingId AS TargetConfigurationSettingId, 
		--DELETED.Name AS TargetName, 
		--DELETED.Value AS TargetValue, 
		--INSERTED.ConfigurationSettingId AS SourceConfigurationSettingId, 
		--INSERTED.Name AS SourceName, 
		--INSERTED.Value AS SourceValue; 
		--SELECT @@ROWCOUNT
	;

	TRUNCATE TABLE dbo.LEO_Temp_ConfigurationSetting
	

	-- 2. merge ports

	MERGE dbo.LEO_Port AS TARGET
	USING dbo.LEO_Temp_Port AS SOURCE 
	ON (TARGET.LeopardId = SOURCE.LeopardId
	AND TARGET.Name = SOURCE.Name)
 
		--When records are matched, update the records if there is any change
		WHEN MATCHED AND TARGET.[Description] <> SOURCE.[Description] THEN 
			UPDATE SET TARGET.[Description] = SOURCE.[Description],
				       TARGET.LastOperation = GetDate(),
					   TARGET.Archived = 0

		--When record is not matched, insert the temp records to live table
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT (LeopardId, Name, [Description], LastOperation, Archived) 
			VALUES (SOURCE.LeopardId, SOURCE.Name, SOURCE.[Description], GetDate(), 0)

		--When there is a row that exists in the live table and same record does not exist in temp table then archive  the value in target table
		WHEN NOT MATCHED BY SOURCE THEN 
			UPDATE SET TARGET.LastOperation = GetDate(),
					   TARGET.Archived = 1

		--OUTPUT $action, 
		--DELETED.LeopardId AS TargetLeopardId, 
		--DELETED.LeoPortId AS TargetLeoPortId, 
		--DELETED.Name AS TargetPortName, 
		--DELETED.[Description] AS TargetPortDescription, 
		--INSERTED.LeopardId AS SourceLeopardId, 
		--INSERTED.LeoPortId AS SourceLeoPortId, 
		--INSERTED.Name AS SourcePortName, 
		--INSERTED.[Description] AS SourcePortDescription; 
		--SELECT @@ROWCOUNT
	;

	TRUNCATE TABLE dbo.LEO_Temp_Port
	

	-- 3. merge resources

	MERGE dbo.LEO_Resource AS TARGET
	USING dbo.LEO_Temp_Resource AS SOURCE 
	ON (TARGET.LeopardId = SOURCE.LeopardId
	AND TARGET.Name = SOURCE.Name)
 
		--When records are matched, update the records if there is any change
		WHEN MATCHED AND TARGET.Total <> SOURCE.Total 
					  OR TARGET.Available <> SOURCE.Available THEN 
			UPDATE SET TARGET.Total = SOURCE.Total,
					   TARGET.Available = SOURCE.Available,
				       TARGET.LastOperation = GetDate(),
					   TARGET.Archived = 0

		--When record is not matched, insert the temp records to live table
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT (LeopardId, Name, Total, Available, LastOperation, Archived) 
			VALUES (SOURCE.LeopardId, SOURCE.Name, SOURCE.Total, SOURCE.Available, GetDate(), 0)

		--When there is a row that exists in the live table and same record does not exist in temp table then archive  the value in target table
		WHEN NOT MATCHED BY SOURCE THEN 
			UPDATE SET TARGET.LastOperation = GetDate(),
					   TARGET.Archived = 1

		--OUTPUT $action, 
		--DELETED.LeopardId AS TargetLeopardId, 
		--DELETED.LeoResourceId AS TargetLeoResourceId, 
		--DELETED.Name AS TargetResourceName, 
		--DELETED.Total AS TargetResourceTotal, 
		--DELETED.Available AS TargetResourceAvailable, 
		--INSERTED.LeopardId AS SourceLeopardId, 
		--INSERTED.LeoResourceId AS SourceLeoResourceId, 
		--INSERTED.Name AS SourceResourceName, 
		--INSERTED.Total AS SourceResourceTotal, 
		--INSERTED.Available AS SourceResourceAvailable;
		--SELECT @@ROWCOUNT
	;

	TRUNCATE TABLE dbo.LEO_Temp_Resource
	

END

GO
