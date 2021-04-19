SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[proc_KB_GetFoldersByCustomer] (@uid UNIQUEIDENTIFIER)
AS
BEGIN

	--DECLARE @uid UNIQUEIDENTIFIER
	--SET @uid = N'C9F5C0CD-FD03-4512-A78A-A10551F91B4B'

	SELECT fo.FolderId, fo.Name, fo.Description, fi.FileId, fi.FName, fi.Ext,fi.Url, fi.Description AS FileDescription,fi.Acknowledge, ft.Name AS FIleType
	FROM dbo.KB_Folder fo
	LEFT JOIN dbo.KB_FileFolder ff ON ff.FolderId = fo.FolderId
	LEFT JOIN dbo.KB_File fi ON fi.FileId = ff.FileId
	LEFT JOIN dbo.KB_FileType ft ON ft.FileTypeId = fi.FileTypeId
	INNER JOIN dbo.[User] u ON u.CustomerID = fo.CustomerId
	Where UserID = @uid
	  AND fi.Archived = 0
	  AND fo.Archived = 0
	ORDER BY fo.Name

END	



GO
