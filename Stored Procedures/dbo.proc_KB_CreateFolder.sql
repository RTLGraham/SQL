SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_KB_CreateFolder]
	@folderName VARCHAR(MAX),
	@description VARCHAR(MAX),
	@uid UNIQUEIDENTIFIER
AS
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
	
	SELECT SCOPE_IDENTITY() AS folderId	

END	

GO
