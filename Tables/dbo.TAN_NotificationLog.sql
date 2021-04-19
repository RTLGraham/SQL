CREATE TABLE [dbo].[TAN_NotificationLog]
(
[NotificationId] [uniqueidentifier] NOT NULL,
[TriggerId] [uniqueidentifier] NOT NULL,
[RecipientAddress] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Header] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Body] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NotificationDateTime] [datetime] NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF__TAN_Notif__Archi__0A0A2FAC] DEFAULT ((0)),
[NotificationTypeId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_NotificationLog] ADD CONSTRAINT [PK_TAN_NotificationLog] PRIMARY KEY CLUSTERED  ([NotificationId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_NotificationLog] ADD CONSTRAINT [FK_TAN_NotificationLog_TAN_Trigger] FOREIGN KEY ([TriggerId]) REFERENCES [dbo].[TAN_Trigger] ([TriggerId])
GO
