SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =====================================================
-- Author:		<Jamie Bartleet>
-- Create date: <2017-10-20>
-- Description:	<Update Leopard app config file details>
-- =====================================================
CREATE PROCEDURE [dbo].[proc_LEO_WriteAppConfigFile]
	@IvhId UNIQUEIDENTIFIER,
	@AppName VARCHAR(255),
	@FileName VARCHAR(255),
	@Timestamp DATETIME,
	@Size BIGINT	
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @IvhId UNIQUEIDENTIFIER,
	--        @AppName VARCHAR(255),
	--        @FileName VARCHAR(255), 
	--        @Timestamp DATETIME,
	--        @Size BIGINT
	        
	--SET @IvhId      = 'c7719ccb-b79e-4b34-b4d8-fd0c1c3a7b63'
	--SET @AppName    = 'Leopard'
	--SET @FileName   = 'Phonebook.xml'
	--SET @Timestamp  = '2015-07-03 12:34:18'
	--SET @Size       = 6846

	  
	IF (SELECT COUNT(*)
	    FROM dbo.LEO_ApplicationConfigurationFile acf
			INNER JOIN dbo.LEO_Leopard l ON acf.LeopardId = l.LeopardId
			INNER JOIN dbo.LEO_ApplicationConfiguration ac ON ac.applicationConfigurationid = acf.applicationConfigurationid
			INNER JOIN dbo.LEO_Application a ON ac.ApplicationId = a.ApplicationId
			INNER JOIN dbo.LEO_Configuration c ON ac.ConfigurationId = c.ConfigurationId
			WHERE l.IVHId = @IvhId
			  AND a.Name = @AppName
			  AND c.Name = @FileName) = 0
	
		-- write a Leopard Application Configuration
		INSERT INTO dbo.LEO_ApplicationConfigurationFile
				( LeopardId ,
				  ApplicationConfigurationId ,
				  [Timestamp] ,
				  Size
				)
		SELECT l.LeopardId, ac.ApplicationConfigurationId, @Timestamp, @size
		FROM dbo.LEO_Leopard l 
		CROSS JOIN dbo.LEO_ApplicationConfiguration ac
		INNER JOIN dbo.LEO_Application a ON ac.ApplicationId = a.ApplicationId
		INNER JOIN dbo.LEO_Configuration c ON ac.ConfigurationId = c.ConfigurationId
		WHERE l.IVHId = @IvhId
		  AND a.Name = @AppName
		  AND c.Name = @FileName
		;
	ELSE
		-- update a Leopard Application Configuration
		UPDATE dbo.LEO_ApplicationConfigurationFile
		SET [Timestamp] = @Timestamp,
			SIZE = @size		
		FROM dbo.LEO_ApplicationConfigurationFile acf
		INNER JOIN dbo.LEO_Leopard l ON acf.LeopardId = l.LeopardId
		INNER JOIN dbo.LEO_ApplicationConfiguration ac ON ac.applicationConfigurationid = acf.applicationConfigurationid
		INNER JOIN dbo.LEO_Application a ON ac.ApplicationId = a.ApplicationId
		INNER JOIN dbo.LEO_Configuration c ON ac.ConfigurationId = c.ConfigurationId
		WHERE l.IVHId = @IvhId
		  AND a.Name = @AppName
		  AND c.Name = @FileName		
		;
	
END


GO
