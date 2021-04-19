CREATE TABLE [dbo].[UserMobileNotificationVideo]
(
[UserMobileNotificationVideoId] [int] NOT NULL IDENTITY(1, 1),
[UserMobileNotificationId] [uniqueidentifier] NULL,
[Registration] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreationCodeId] [int] NOT NULL,
[VehicleId] [uniqueidentifier] NOT NULL,
[UserID] [uniqueidentifier] NOT NULL,
[MobileToken] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VideoEventDateTime] [datetime] NOT NULL,
[PushType] [int] NOT NULL,
[LastOperation] [datetime] NULL CONSTRAINT [DF__UserMobileNotificationVideo_LastOperation] DEFAULT (getdate()),
[PushDate] [datetime] NULL,
[PushStatus] [bit] NULL,
[ReceivedDate] [datetime] NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF__UserMobileNotificationVideo_Archived] DEFAULT ((0)),
[DeviceId] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NotificationType] [int] NOT NULL CONSTRAINT [DF__UserMobil__Notif__19775BC5] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserMobileNotificationVideo] ADD CONSTRAINT [PK_UserMobileNotificationVideo] PRIMARY KEY CLUSTERED  ([UserMobileNotificationVideoId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UserMobileNotificationVideo_UserPushType] ON [dbo].[UserMobileNotificationVideo] ([UserID], [PushType], [ReceivedDate], [PushDate], [DeviceId], [NotificationType]) INCLUDE ([UserMobileNotificationVideoId], [Registration], [CreationCodeId], [VehicleId], [MobileToken], [VideoEventDateTime]) ON [PRIMARY]
GO
