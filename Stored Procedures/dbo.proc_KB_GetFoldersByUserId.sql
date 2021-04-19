SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_KB_GetFoldersByUserId] (@uid UNIQUEIDENTIFIER)
AS
BEGIN

	--DECLARE @uid UNIQUEIDENTIFIER
	--SET @uid = N'C9F5C0CD-FD03-4512-A78A-A10551F91B4B'
	--SET @uid = N'd5bd4f3e-4df3-4f6b-8a7d-91709ce04b7d'

	SELECT fo.FolderId, fo.Name, fo.Description, fi.FileId, fi.FName, fi.Ext,fi.Url, fi.Description AS FileDescription, fi.FileIdCustom,fi.Acknowledge, ft.Name AS FileType, kba.AssessmentId,kba.IsEnabled
	FROM dbo.KB_Folder fo
	LEFT JOIN dbo.KB_FileFolder ff ON ff.FolderId = fo.FolderId
	LEFT JOIN dbo.KB_File fi ON fi.FileId = ff.FileId AND fi.Archived = 0
	LEFT JOIN dbo.KB_FileType ft ON ft.FileTypeId = fi.FileTypeId
	LEFT JOIN dbo.KB_Assessment kba ON kba.FileId = fi.FileId AND kba.Archived = 0
	INNER JOIN dbo.[User] u ON u.CustomerID = fo.CustomerId
	Where UserID = @uid
	  AND fo.Archived = 0

	UNION

	SELECT -1 AS FolderId, NULL as Name, NULL AS Description, fi.FileId, fi.FName, fi.Ext,fi.Url, fi.Description AS FileDescription, fi.FileIdCustom,fi.Acknowledge, ft.Name AS FileType, kba.AssessmentId,kba.IsEnabled
	FROM dbo.KB_File fi
	LEFT JOIN dbo.KB_FileFolder ff ON fi.FileId = ff.FileId
	LEFT JOIN dbo.KB_FileType ft ON ft.FileTypeId = fi.FileTypeId
	LEFT JOIN dbo.KB_Assessment kba ON kba.FileId = fi.FileId AND kba.Archived = 0
	INNER JOIN dbo.[User] u ON u.CustomerID = fi.CustomerId
	Where UserID = @uid
	  AND fi.Archived = 0
	  AND ff.FileId IS NULL
	ORDER BY fo.Name

END	


GO
