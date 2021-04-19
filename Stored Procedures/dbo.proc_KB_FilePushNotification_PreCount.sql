SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_KB_FilePushNotification_PreCount] @fileId INT, @folderId INT
AS
BEGIN

	--DECLARE @fileId INT,
	--		@folderId INT
	--SET @fileId = 529
	--SET @folderId = 123

	--SELECT * FROM dbo.KB_File f INNER JOIN dbo.KB_FileFolder ff ON ff.FileId = f.FileId WHERE f.FName = 'test f'


	DECLARE @notifCount INT,
			@driverCount INT

	SELECT @notifCount = 0, @driverCount = 0

	--If file doesn’t have assessment, and doesn’t require acknowledgement - register notification only if user has not opened the file 

	SELECT	@notifCount = @notifCount + ISNULL(COUNT(*), 0),
			@driverCount = @driverCount + ISNULL(COUNT(DISTINCT d.DriverId), 0)
	FROM dbo.KB_FileFolder ff
	INNER JOIN dbo.KB_File fi ON fi.FileId = ff.FileId
	INNER JOIN dbo.KB_DriverGroupFolder dgf ON ff.FolderId = dgf.FolderId
	INNER JOIN dbo.GroupDetail gd ON gd.GroupId = dgf.DriverGroupId
	INNER JOIN dbo.Driver d ON d.DriverId = gd.EntityDataId
	INNER JOIN dbo.UserMobileToken umt ON umt.UserId = d.DriverId
	LEFT JOIN dbo.KB_DriverHistory dh ON dh.FileId = fi.FileId AND dh.DriverIntId = d.DriverIntId
	WHERE ff.FileId = @fileId
	  AND ff.FolderId = @folderId
	  AND d.Archived = 0
	  AND umt.Archived = 0
	  AND LEN(umt.MobileToken) > 20
	  AND dh.DriverHistoryId IS NULL --notify only those drivers who have not yet opened the file
	  
	  --If file doesn’t have assessment, but requires acknowledgement - register notification only if user has not acknowledged the file. File open doesn’t matter for this case.

	SELECT	@notifCount = @notifCount + ISNULL(COUNT(*), 0),
			@driverCount = @driverCount + ISNULL(COUNT(DISTINCT d.DriverId), 0)
	FROM dbo.KB_FileFolder ff
	INNER JOIN dbo.KB_File fi ON fi.FileId = ff.FileId
	INNER JOIN dbo.KB_DriverGroupFolder dgf ON ff.FolderId = dgf.FolderId
	INNER JOIN dbo.GroupDetail gd ON gd.GroupId = dgf.DriverGroupId
	INNER JOIN dbo.Driver d ON d.DriverId = gd.EntityDataId
	INNER JOIN dbo.UserMobileToken umt ON umt.UserId = d.DriverId
	LEFT JOIN dbo.KB_DriverHistory dh ON dh.FileId = fi.FileId AND dh.DriverIntId = d.DriverIntId
	LEFT JOIN dbo.KB_Assessment a ON a.FileId = fi.FileId
	WHERE ff.FileId = @fileId
	  AND ff.FolderId = @folderId
	  AND d.Archived = 0
	  AND umt.Archived = 0
	  AND LEN(umt.MobileToken) > 20
	  --AND dh.DriverHistoryId IS NULL --notify only those drivers who have not yet opened the file
	  AND a.AssessmentId IS NULL
	  AND fi.Acknowledge = 1
	  AND dh.isAcknowledged = 0
	 

--If file has the assessment - register notification only if user has not passed it. Acknowledgement and file open don’t matter for this case.

	SELECT	@notifCount = @notifCount + ISNULL(COUNT(*), 0),
			@driverCount = @driverCount + ISNULL(COUNT(DISTINCT d.DriverId), 0)
	FROM dbo.KB_FileFolder ff
	INNER JOIN dbo.KB_File fi ON fi.FileId = ff.FileId
	INNER JOIN dbo.KB_DriverGroupFolder dgf ON ff.FolderId = dgf.FolderId
	INNER JOIN dbo.GroupDetail gd ON gd.GroupId = dgf.DriverGroupId
	INNER JOIN dbo.Driver d ON d.DriverId = gd.EntityDataId
	INNER JOIN dbo.UserMobileToken umt ON umt.UserId = d.DriverId
	LEFT JOIN dbo.KB_DriverHistory dh ON dh.FileId = fi.FileId AND dh.DriverIntId = d.DriverIntId
	LEFT JOIN dbo.KB_Assessment a ON a.FileId = fi.FileId
	WHERE ff.FileId = @fileId
	  AND ff.FolderId = @folderId
	  AND d.Archived = 0
	  AND umt.Archived = 0
	  AND LEN(umt.MobileToken) > 20
	  --AND dh.DriverHistoryId IS NULL --notify only those drivers who have not yet opened the file
	  AND a.AssessmentId IS NOT NULL
	  AND dh.isAssessed = 0

	SELECT	@notifCount AS NotificationCount, 
			@driverCount AS DriverCount
END

GO
