SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROC [dbo].[proc_KB_FileFolderLink]
	@fileId INT,
	@folderId INT
AS
BEGIN

	INSERT INTO dbo.KB_FileFolder ( FileId, FolderId )
	VALUES  ( @fileId, @folderId )

END	


GO
