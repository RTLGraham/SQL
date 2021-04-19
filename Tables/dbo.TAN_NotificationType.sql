CREATE TABLE [dbo].[TAN_NotificationType]
(
[NotificationTypeId] [int] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF__TAN_Notif__Archi__1A209BE4] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF__TAN_Notif__LastO__1B14C01D] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_NotificationType] ADD CONSTRAINT [PK_TAN_NotificationType] PRIMARY KEY CLUSTERED  ([NotificationTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TAN_NotificationType] ON [dbo].[TAN_NotificationType] ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
