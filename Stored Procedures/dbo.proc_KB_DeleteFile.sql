SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROC [dbo].[proc_KB_DeleteFile]
	@fileId INT
AS
BEGIN

	UPDATE dbo.KB_File
	SET Archived = 1, LastOperation = GETDATE()
	WHERE FileId = @fileId

END	


GO
