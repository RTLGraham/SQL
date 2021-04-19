SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_MSG_SendChatroomMessage](@cid INT, @uid UNIQUEIDENTIFIER, @msg NVARCHAR(MAX))
AS

	--DECLARE @cid INT,
	--		@uid UNIQUEIDENTIFIER,
	--		@msg NVARCHAR(MAX)
	--SET @cid = 1
	--SET @uid = N'FD213638-5DE1-423B-B8FF-8B9270FEAB18'
	--SET @msg = 'Another message sent from driver Dmitrijs.'

-- 1. Create the message and determine the messageId

	DECLARE @msgid INT

	INSERT INTO dbo.MSG_Message (Messagetext, MessageOwner, TimeSent, Archived, LastModified)
	VALUES  (@msg, @uid, GETUTCDATE(), 0, GETDATE())

	SET @msgid = SCOPE_IDENTITY()
	
-- 2. If user not already a participant, add to the MSG_ChatroomParticipant table

	INSERT INTO dbo.MSG_ChatroomParticipant (ChatroomId, ParticipantId, LastRequestedId, Archived, LastModified)
	SELECT @cid, @uid, 0, 0, GETDATE()
	WHERE NOT EXISTS (
		SELECT *
		FROM dbo.MSG_ChatroomParticipant
		WHERE ChatroomId =@cid AND ParticipantId = @uid)

-- 3. Create entries for this message for all participants in the MSG_ChatroomParticipantMessage table, incrementing to the next LastUpdateId

	DECLARE @nextid INT
	SELECT @nextid = ISNULL(MAX(cpm.LastUpdateId), 0) + 1
	FROM dbo.MSG_ChatroomParticipantMessage cpm
		INNER JOIN dbo.MSG_ChatroomParticipant cp ON cp.ChatroomParticipantId = cpm.ChatroomParticipantId
	WHERE cp.ChatroomId = @cid

	INSERT INTO dbo.MSG_ChatroomParticipantMessage (ChatroomParticipantId, MessageId, TimeReceived, TimeRead, Archived, LastModified, LastUpdateId, VehicleModeId)
	SELECT cp.ChatroomParticipantId, @msgid, NULL, NULL, 0, GETDATE(), @nextid, vma.VehicleModeId
	FROM dbo.MSG_ChatroomParticipant cp
	LEFT JOIN dbo.Driver d ON cp.ParticipantId = d.DriverId
	LEFT JOIN dbo.VehicleModeActivity vma ON d.DriverIntId = vma.StartDriverIntId AND GETUTCDATE() > vma.StartDate AND vma.EndDate IS NULL	
	WHERE cp.ChatroomId = @cid

-- 4. Send the push notification to the driver ONLY - don't send notification if the message initiates from the driver
	INSERT INTO dbo.UserMobileNotificationVideo
			( UserMobileNotificationId ,
			  Registration ,
			  CreationCodeId ,
			  VehicleId ,
			  UserID ,
			  MobileToken ,
			  VideoEventDateTime ,
			  PushType ,
			  LastOperation ,
			  PushDate ,
			  PushStatus ,
			  ReceivedDate ,
			  Archived ,
			  DeviceId ,
			  NotificationType
			)
	SELECT	  NEWID() , -- UserMobileNotificationId - uniqueidentifier
			  N'' , -- Registration - nvarchar(max)
			  0 , -- CreationCodeId - int
			  NEWID() , -- VehicleId - uniqueidentifier
			  umt.UserId , -- UserID - uniqueidentifier
			  umt.MobileToken , -- MobileToken - nvarchar(max)
			  GETDATE() , -- VideoEventDateTime - datetime
			  2 , -- PushType - int
			  GETDATE() , -- LastOperation - datetime
			  NULL , -- PushDate - datetime
			  NULL , -- PushStatus - bit
			  NULL , -- ReceivedDate - datetime
			  0 , -- Archived - bit
			  umt.DeviceId , -- DeviceId - nvarchar(100)
			  2  -- NotificationType - int
	FROM dbo.UserMobileToken umt
		INNER JOIN dbo.MSG_ChatroomParticipant cp ON umt.UserId = cp.ParticipantId
		INNER JOIN dbo.Driver d ON d.DriverId = cp.ParticipantId
	WHERE ChatroomId = @cid
		AND umt.Archived = 0
		AND umt.LastOperation > '2017-02-01 00:00' AND LEN(umt.MobileToken) > 20
		AND cp.ParticipantId != @uid

-- 5. Return resultset	

	SELECT	m.MessageId AS MessageId,
			cp.ChatroomId,
			m.Messagetext AS MessageText,
			dbo.GetDriverOrUserNameByUid(@uid) AS SenderName,
			@uid AS SenderID,
			m.TimeSent,
			cp.ParticipantId,
			cp.LastRequestedId AS LastUpdateId
	FROM dbo.MSG_ChatroomParticipantMessage cpm
		INNER JOIN dbo.MSG_Message m ON m.MessageId = cpm.MessageId
		INNER JOIN dbo.MSG_ChatroomParticipant cp ON cp.ChatroomParticipantId = cpm.ChatroomParticipantId
		LEFT JOIN dbo.[User] u ON cp.ParticipantId = u.UserID
		LEFT JOIN dbo.Driver d ON cp.ParticipantId = d.DriverId
		LEFT JOIN dbo.[User] su ON su.UserID = @uid
		LEFT JOIN dbo.Driver sd ON sd.DriverId = @uid
	WHERE cpm.MessageId = @msgid

GO
