SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_UserMobileNotificationsVideo_GetAllUnsent]
AS
	SELECT UserMobileNotificationVideoId ,
           Registration ,
           CreationCodeId ,
           VehicleId ,
           UserID ,
           MobileToken ,
           VideoEventDateTime ,
           CASE WHEN PushType = 1 THEN 'Android' ELSE 'Apple' END AS PushType,
		   NotificationType
	FROM dbo.UserMobileNotificationVideo
	WHERE PushDate IS NULL AND PushStatus IS NULL

GO
