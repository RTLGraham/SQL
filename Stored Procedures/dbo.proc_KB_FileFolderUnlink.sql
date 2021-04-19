SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[proc_KB_FileFolderUnlink]
	@fileId INT,
	@folderId INT
AS
BEGIN

	DELETE FROM dbo.KB_FileFolder
	WHERE FileId = @fileId AND FolderId = @folderId

END	


GO
