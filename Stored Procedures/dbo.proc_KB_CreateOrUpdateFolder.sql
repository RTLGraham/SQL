SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROC [dbo].[proc_KB_CreateOrUpdateFolder]
	@folderName VARCHAR(MAX),
	@description VARCHAR(MAX),
	@uid UNIQUEIDENTIFIER,
	@folderId INT = NULL
AS
BEGIN
	DECLARE @t_folderid INT = NULL 

	SELECT @t_folderid = FolderId
	FROM dbo.KB_Folder
	WHERE @folderId = FolderId

	IF(@t_folderid IS NULL)
	BEGIN
		INSERT INTO dbo.KB_Folder
		        ( Name ,
		          Description ,
		          CustomerId ,
		          Archived ,
		          LastOperation
		        )
		SELECT @folderName, @description, u.CustomerID, 0, GETDATE()
		FROM dbo.[User] u
		WHERE u.UserID = @uid
		
		SELECT CAST(SCOPE_IDENTITY() AS INT) AS folderId	
	END ELSE
		BEGIN
		UPDATE dbo.KB_Folder
		SET Name = @folderName,
		Description = @description
		WHERE FolderId = @t_folderid
		SELECT @t_folderid

	END
END	


GO
