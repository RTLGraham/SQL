SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ========================================================
-- Author:		<Jamie Bartleet>
-- Create date: <2017-10-25>
-- Description:	<Update Leopard app component file details>
-- ========================================================
CREATE PROCEDURE [dbo].[proc_LEO_WriteAppComponentFile]
	@IvhId UNIQUEIDENTIFIER,
	@AppName VARCHAR(255),
	@FileName VARCHAR(255),
	@Version VARCHAR(50),
	@Timestamp DATETIME,
	@Size BIGINT	
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @IvhId UNIQUEIDENTIFIER,
	--        @AppName VARCHAR(255),
	--        @FileName VARCHAR(255), 
 --           @Version VARCHAR(50),
	--        @Timestamp DATETIME,
	--        @Size BIGINT
	        
	--SET @IvhId      = '7B7A6F42-F7E0-4F3B-ADFA-06C2B1FDEEE4'
	--SET @AppName    = 'Leopard'
	--SET @FileName   = 'RTL.Compact.Leopard.Phone.Resources.dll'
	--SET @Version    = '1.4.3'
	--SET @Timestamp  = '2017-08-22 15:45:16'
	--SET @Size       = 42496

	  
	IF (SELECT COUNT(*)
	    FROM dbo.LEO_ApplicationComponentFile acf
			INNER JOIN dbo.LEO_Leopard l ON acf.LeopardId = l.LeopardId
			INNER JOIN dbo.LEO_ApplicationComponent ac ON ac.ApplicationComponentId = acf.ApplicationComponentId
			INNER JOIN dbo.LEO_Application a ON ac.ApplicationId = a.ApplicationId
			INNER JOIN dbo.LEO_Component c ON ac.ComponentId = c.ComponentId
			WHERE l.IVHId = @IvhId
			  AND a.Name = @AppName
			  AND c.Name = @FileName) = 0
	
		INSERT INTO dbo.LEO_ApplicationComponentFile
				( LeopardId ,
				  ApplicationComponentId ,
				  [Version],
				  [Timestamp] ,
				  Size
				)
		SELECT l.LeopardId, ac.ApplicationComponentId, @Version, @Timestamp, @size
		FROM dbo.LEO_Leopard l 
		CROSS JOIN dbo.LEO_ApplicationComponent ac
		INNER JOIN dbo.LEO_Application a ON ac.ApplicationId = a.ApplicationId
		INNER JOIN dbo.LEO_Component c ON ac.ComponentId = c.ComponentId
		WHERE l.IVHId = @IvhId
		  AND a.Name = @AppName
		  AND c.Name = @FileName
		;
	ELSE
		UPDATE dbo.LEO_ApplicationComponentFile
		SET [Version] = @Version,
			[Timestamp] = @Timestamp,
			SIZE = @size		
		FROM dbo.LEO_ApplicationComponentFile acf
		INNER JOIN dbo.LEO_Leopard l ON acf.LeopardId = l.LeopardId
		INNER JOIN dbo.LEO_ApplicationComponent ac ON ac.ApplicationComponentId = acf.ApplicationComponentId
		INNER JOIN dbo.LEO_Application a ON ac.ApplicationId = a.ApplicationId
		INNER JOIN dbo.LEO_Component c ON ac.ComponentId = c.ComponentId
		WHERE l.IVHId = @IvhId
		  AND a.Name = @AppName
		  AND c.Name = @FileName		
		;

END

GO
