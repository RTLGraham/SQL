SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_UserMobileNotificationsVideo_GetUnacked]
(
	@userId UNIQUEIDENTIFIER,
	@token NVARCHAR(MAX),
	@pushType INT
)
AS
	--DECLARE @userId UNIQUEIDENTIFIER,
	--		@token NVARCHAR(MAX),
	--		@pushType INT
	--SELECT	@userId = N'54623E87-BF00-4818-9FAD-9170DA986E4D', 
	--		@token = '3e9eca4ddfbadd508cdece793c3e6940d8ab71ca71eec3f7c7688b5dc4f0c952', 
	--		@pushType = 2

	SELECT UserMobileNotificationVideoId ,
           Registration ,
           CreationCodeId ,
           VehicleId ,
           UserID ,
           MobileToken ,
           VideoEventDateTime ,
           CASE WHEN PushType = 1 THEN 'Android' ELSE 'Apple' END AS PushType 
	FROM dbo.UserMobileNotificationVideo
	WHERE PushDate IS NOT NULL 
		AND ReceivedDate IS NULL 
		AND PushType = @pushType
		AND UserID = @userId
		AND DeviceId = @token
		AND PushDate BETWEEN DATEADD(DAY, -7, GETDATE()) AND GETDATE()
		AND NotificationType NOT IN (2) -- specify the notification types that should not appear on the list of notifications
		--AND MobileToken LIKE '%' + @token + '%'

GO
