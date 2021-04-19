SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_UserMobileNotifications_Process]
AS
	
	UPDATE dbo.UserMobileNotification SET ProcessInd = 1 WHERE ProcessInd = 0

	DECLARE @data TABLE
	(
		UserMobileNotificationId UNIQUEIDENTIFIER,
		Registration NVARCHAR(MAX),
		CreationCodeId INT,
		VehicleId UNIQUEIDENTIFIER,
		UserID UNIQUEIDENTIFIER,
		MobileToken NVARCHAR(250),
		DeviceId NVARCHAR(100),
		VideoEventDateTime DATETIME
	)
	DECLARE @results TABLE
	(
		UserMobileNotificationId UNIQUEIDENTIFIER,
		Registration NVARCHAR(MAX),
		CreationCodeId INT,
		VehicleId UNIQUEIDENTIFIER,
		UserID UNIQUEIDENTIFIER,
		MobileToken NVARCHAR(MAX),
		DeviceId NVARCHAR(100),
		VideoEventDateTime DATETIME,
		PushType INT -- 1 for Android, 2 for Apple
	)

	INSERT INTO @data
	        ( UserMobileNotificationId ,
	          Registration ,
	          CreationCodeId ,
	          VehicleId ,
	          UserID ,
	          MobileToken ,
			  DeviceId,
	          VideoEventDateTime
	        )
	SELECT DISTINCT
		umn.UserMobileNotificationId, 
		v.Registration, cc.CreationCodeId, v.VehicleId, u.UserID, umt.MobileToken, umt.DeviceId,
		dbo.TZ_GetTime(i.EventDateTime, DEFAULT, u.UserID) AS VideoEventDateTime
	FROM dbo.UserMobileNotification umn
		INNER JOIN dbo.CAM_Incident i ON i.EventId = umn.EventId
		INNER JOIN dbo.CreationCode cc ON cc.CreationCodeId = i.CreationCodeId
		INNER JOIN dbo.Vehicle v ON v.VehicleIntId = umn.VehicleIntID
		INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
		INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
		INNER JOIN dbo.UserGroup ug ON ug.GroupId = g.GroupId
		INNER JOIN dbo.[User] u ON u.UserID = ug.UserId
		INNER JOIN dbo.UserPreference up ON up.UserID = u.UserID
		INNER JOIN dbo.UserMobileToken umt ON umt.UserId = u.UserID
	WHERE 
		u.Archived = 0 AND ug.Archived = 0 AND g.Archived = 0 AND g.IsParameter = 0 AND g.GroupTypeId = 1
		AND umn.CreationCodeId = 137 /* 137 - High Video Complete; 138 - Video For review*/
		AND up.NameID = 1095 AND up.Archived = 0 AND up.Value = '1' /* Analyst: 1095; Coach: 1097*/
		AND umn.ProcessInd = 1
		AND umt.Archived = 0
		AND LEN(umt.MobileToken) > 20 AND umt.Archived = 0
	GROUP BY umn.UserMobileNotificationId, v.Registration, cc.CreationCodeId, v.VehicleId, u.UserID, umt.MobileToken, umt.DeviceId, i.EventDateTime
	
	INSERT INTO @data
	        ( UserMobileNotificationId ,
	          Registration ,
	          CreationCodeId ,
	          VehicleId ,
	          UserID ,
	          MobileToken ,
			  DeviceId,
	          VideoEventDateTime
	        )
	SELECT DISTINCT
		umn.UserMobileNotificationId, 
		v.Registration, cc.CreationCodeId, v.VehicleId, u.UserID, umt.MobileToken, umt.DeviceId,
		dbo.TZ_GetTime(i.EventDateTime, DEFAULT, u.UserID) AS VideoEventDateTime
	FROM dbo.UserMobileNotification umn
		INNER JOIN dbo.CAM_Incident i ON i.EventId = umn.EventId
		INNER JOIN dbo.CreationCode cc ON cc.CreationCodeId = i.CreationCodeId
		INNER JOIN dbo.Vehicle v ON v.VehicleIntId = umn.VehicleIntID
		INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
		INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
		INNER JOIN dbo.UserGroup ug ON ug.GroupId = g.GroupId
		INNER JOIN dbo.[User] u ON u.UserID = ug.UserId
		INNER JOIN dbo.UserPreference up ON up.UserID = u.UserID
		INNER JOIN dbo.UserMobileToken umt ON umt.UserId = u.UserID
	WHERE 
		u.Archived = 0 AND ug.Archived = 0 AND g.Archived = 0 AND g.IsParameter = 0 AND g.GroupTypeId = 1
		AND umn.CreationCodeId IN (138, 144) /* 137 - High Video Complete; 138 - Video For review; 144 - Video Requires coaching*/
		AND up.NameID = 1097 AND up.Archived = 0 AND up.Value = '1' /* Analyst: 1095; Coach: 1097*/
		AND umn.ProcessInd = 1
		AND umt.Archived = 0
		AND LEN(umt.MobileToken) > 20 AND umt.Archived = 0
	GROUP BY umn.UserMobileNotificationId, v.Registration, cc.CreationCodeId, v.VehicleId, u.UserID, umt.MobileToken, umt.DeviceId, i.EventDateTime
	

	--INSERT INTO @results
	--        ( UserMobileNotificationId ,
	--          Registration ,
	--          CreationCodeId ,
	--          VehicleId ,
	--          UserID ,
	--          MobileToken ,
	--		  DeviceId,
	--          VideoEventDateTime ,
	--          PushType
	--        )
	--SELECT UserMobileNotificationId ,
 --          Registration ,
 --          CreationCodeId ,
 --          VehicleId ,
 --          UserID ,
 --          MobileToken   = STUFF((
	--			SELECT ', ' + MobileToken FROM @data r2 WHERE r1.UserMobileNotificationId = r2.UserMobileNotificationId AND r1.UserId = r2.UserId AND LEN(r2.MobileToken) = 22
 --       FOR XML PATH ('')),1,2,''),
	--		NULL, -- Device ID is not signifficant for Android
 --          VideoEventDateTime,
	--	   1 AS PushType
	--	FROM @data r1
	--	WHERE LEN(r1.MobileToken) = 22
	--	GROUP BY UserMobileNotificationId ,Registration ,CreationCodeId ,VehicleId ,UserID ,VideoEventDateTime
	
	INSERT INTO @results
	        ( UserMobileNotificationId ,
	          Registration ,
	          CreationCodeId ,
	          VehicleId ,
	          UserID ,
	          MobileToken ,
			  DeviceId,
	          VideoEventDateTime ,
	          PushType
	        )
	SELECT UserMobileNotificationId ,
           Registration ,
           CreationCodeId ,
           VehicleId ,
           UserID ,
		   r1.MobileToken,
		   r1.DeviceId,
           VideoEventDateTime,
		   CASE WHEN LEN(DeviceId) <> 36 THEN 1 /*Android*/ ELSE 2 /*'Apple'*/ END AS PushType
	FROM @data r1

	INSERT INTO dbo.UserMobileNotificationVideo
	        ( UserMobileNotificationId ,
	          Registration ,
	          CreationCodeId ,
	          VehicleId ,
	          UserID ,
	          MobileToken ,
			  DeviceId ,
	          VideoEventDateTime ,
	          PushType ,
	          LastOperation
	        )
	SELECT NULL,
			r.Registration ,
           r.CreationCodeId ,
           r.VehicleId ,
           r.UserID ,
           r.MobileToken ,
		   r.DeviceId ,
           r.VideoEventDateTime ,
           r.PushType,
		   GETDATE()
	FROM @results r
	GROUP BY r.Registration ,
           r.CreationCodeId ,
           r.VehicleId ,
           r.UserID ,
           r.MobileToken ,
		   r.DeviceId ,
           r.VideoEventDateTime ,
           r.PushType

	DELETE FROM dbo.UserMobileNotification WHERE ProcessInd = 1

GO
