SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[proc_CAM_CleanTables]
AS

	DECLARE @date DATETIME
	SET @date = DATEADD(dd, -3, GETUTCDATE())

	-- Clean CAM_VideoIn Table
	DELETE FROM dbo.CAM_VideoIn
	WHERE LastOperation < @date

	-- Clean CAM_MetadataIn Table
	DELETE FROM dbo.CAM_MetadataIn
	WHERE LastOperation < @date





GO
