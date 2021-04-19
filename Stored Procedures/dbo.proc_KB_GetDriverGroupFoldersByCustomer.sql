SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE PROC [dbo].[proc_KB_GetDriverGroupFoldersByCustomer] (@cid UNIQUEIDENTIFIER)
AS
BEGIN

	--DECLARE @cid UNIQUEIDENTIFIER
	--SET @cid = N'8428282B-5D84-459C-B26C-A84B77ECBF13'

	SELECT fo.FolderId, fo.Name, fo.Description, dgf.DriverGroupId, gr.GroupName
	FROM dbo.KB_Folder fo
	INNER JOIN dbo.KB_DriverGroupFolder dgf ON dgf.FolderId = fo.FolderId
	LEFT JOIN dbo.[Group] gr ON gr.GroupId = dgf.DriverGroupId
	WHERE fo.CustomerId = @cid
	  AND fo.Archived = 0
	ORDER BY fo.Name

END	


GO
