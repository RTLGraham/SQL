SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[proc_KB_DriverFolderUnlink]
	@driverGroupId UNIQUEIDENTIFIER,
	@folderId INT
AS
BEGIN

	DELETE FROM dbo.KB_DriverGroupFolder
	WHERE DriverGroupId = @driverGroupId AND FolderId = @folderId

END	


GO
