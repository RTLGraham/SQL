SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_UserMobileNotificationsVideo_SetPushDate]
(
	@userMobileNotificationVideoId INT,
	@status BIT,
	@receivedDate DATETIME = NULL
)
AS

	UPDATE dbo.UserMobileNotificationVideo
	SET PushDate = CASE WHEN PushDate IS NULL THEN GETDATE() ELSE PushDate END, 
		PushStatus = @status, 
		ReceivedDate = @receivedDate
	WHERE UserMobileNotificationVideoId = @userMobileNotificationVideoId

GO
