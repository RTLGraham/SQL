SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROC [dbo].[proc_KB_DeleteFolder]
	@folderId INT
AS
BEGIN

	DELETE FROM dbo.KB_FileFolder
	WHERE FolderId = @folderId

	UPDATE dbo.KB_Folder
	SET Archived = 1, LastOperation = GETDATE()
	WHERE FolderId = @folderId

END	


GO
