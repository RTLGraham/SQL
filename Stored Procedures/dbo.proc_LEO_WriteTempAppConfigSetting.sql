SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ===================================================================
-- Author:		<Jamie Bartleet>
-- Create date: <2017-10-25>
-- Description:	<Update Leopard app config setting to temporary table>
-- ===================================================================
CREATE PROCEDURE [dbo].[proc_LEO_WriteTempAppConfigSetting]
	@IvhId UNIQUEIDENTIFIER,
	@AppName VARCHAR(255),
	@FileName VARCHAR(255),
	@SettingName VARCHAR(255),
	@SettingValue VARCHAR(255)	

AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @IvhId UNIQUEIDENTIFIER,
	--        @AppName VARCHAR(255),
	--        @FileName VARCHAR(255), 
	--        @SettingName VARCHAR(255),
	--        @SettingValue VARCHAR(255)
	        
	--SET @IvhId        = '7B7A6F42-F7E0-4F3B-ADFA-06C2B1FDEEE4'
	--SET @AppName      = 'Leopard'
	--SET @FileName     = 'Settings.xml'
	--SET @SettingName  = 'Desc'
	--SET @SettingValue = 'CAMOS'


	if (Select Count(*)
		FROM dbo.LEO_ApplicationConfigurationFile acf
			INNER JOIN dbo.LEO_Leopard l ON acf.LeopardId = l.LeopardId
		Inner JOIN dbo.LEO_Temp_ConfigurationSetting acs ON acs.ApplicationConfigurationFileId = acf.applicationConfigurationFileid
		Inner JOIN dbo.LEO_ApplicationConfiguration ac ON ac.applicationConfigurationid = acf.applicationConfigurationid
		INNER JOIN dbo.LEO_Application a ON ac.ApplicationId = a.ApplicationId
		INNER JOIN dbo.LEO_Configuration c ON ac.ConfigurationId = c.ConfigurationId
		WHERE l.IVHId = @IvhId
		  AND a.Name = @AppName
		  AND c.Name = @FileName
		  AND acs.Name = @SettingName) = 0


		INSERT INTO dbo.LEO_Temp_ConfigurationSetting
				( ApplicationConfigurationFileId ,
				  Name ,
				  Value ,
				  LastOperation ,
				  Archived
				)
		SELECT acf.ApplicationConfigurationFileId, @SettingName, @SettingValue, GetDate(), 0
		FROM dbo.LEO_ApplicationConfigurationFile acf
		INNER JOIN dbo.LEO_Leopard l ON acf.LeopardId = l.LeopardId
		Inner JOIN dbo.LEO_ApplicationConfiguration ac ON ac.applicationConfigurationid = acf.applicationConfigurationid
		INNER JOIN dbo.LEO_Application a ON ac.ApplicationId = a.ApplicationId
		INNER JOIN dbo.LEO_Configuration c ON ac.ConfigurationId = c.ConfigurationId
		WHERE l.IVHId = @IvhId
		  AND a.Name = @AppName
		  AND c.Name = @FileName
		;

	ELSE

		UPDATE dbo.LEO_Temp_ConfigurationSetting
		SET Name = @SettingName,
		    Value = @SettingValue,
			LastOperation = GetDate(),
			Archived = 0
		FROM dbo.LEO_ApplicationConfigurationFile acf
		INNER JOIN dbo.LEO_Leopard l ON acf.LeopardId = l.LeopardId
		Inner JOIN dbo.LEO_ApplicationConfiguration ac ON ac.applicationConfigurationid = acf.applicationConfigurationid
		INNER JOIN dbo.LEO_Application a ON ac.ApplicationId = a.ApplicationId
		INNER JOIN dbo.LEO_Configuration c ON ac.ConfigurationId = c.ConfigurationId
		WHERE l.IVHId = @IvhId
		  AND a.Name = @AppName
		  AND c.Name = @FileName
		;


END

GO
