SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_KB_FilePushNotification] @fileId INT, @folderId INT
AS
BEGIN

	--DECLARE @fileId INT,
	--		@folderId INT
	--SET @fileId = 499
	--SET @folderId = 94


	--If file doesn’t have assessment, and doesn’t require acknowledgement - register notification only if user has not opened the file 

	INSERT INTO dbo.UserMobileNotificationVideo 
		(UserMobileNotificationId, Registration, CreationCodeId, VehicleId, UserID, MobileToken, VideoEventDateTime, PushType, LastOperation, PushDate, PushStatus, ReceivedDate, Archived, DeviceId, NotificationType)
	SELECT	NEWID(),
			'New content: ' + ISNULL(fi.FName,''),
			fi.FileId,
			NULL,
			d.DriverId,
			umt.MobileToken,
			GETDATE(),
			2,
			GETDATE(),
			NULL,
			NULL,
			NULL,
			0,
			umt.DeviceId,
			3 -- KB Knowledgebase Type
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


	INSERT INTO dbo.UserMobileNotificationVideo 
		(UserMobileNotificationId, Registration, CreationCodeId, VehicleId, UserID, MobileToken, VideoEventDateTime, PushType, LastOperation, PushDate, PushStatus, ReceivedDate, Archived, DeviceId, NotificationType)
	SELECT	NEWID(),
			'New content: ' + ISNULL(fi.FName,''),
			fi.FileId,
			NULL,
			d.DriverId,
			umt.MobileToken,
			GETDATE(),
			2,
			GETDATE(),
			NULL,
			NULL,
			NULL,
			0,
			umt.DeviceId,
			3 -- KB Knowledgebase Type
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

	INSERT INTO dbo.UserMobileNotificationVideo 
		(UserMobileNotificationId, Registration, CreationCodeId, VehicleId, UserID, MobileToken, VideoEventDateTime, PushType, LastOperation, PushDate, PushStatus, ReceivedDate, Archived, DeviceId, NotificationType)
	SELECT	NEWID(),
			'New content: ' + ISNULL(fi.FName,''),
			fi.FileId,
			NULL,
			d.DriverId,
			umt.MobileToken,
			GETDATE(),
			2,
			GETDATE(),
			NULL,
			NULL,
			NULL,
			0,
			umt.DeviceId,
			3 -- KB Knowledgebase Type
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





END




GO
