CREATE TABLE [dbo].[TAN_NotificationTemplate]
(
[NotificationTemplateId] [uniqueidentifier] NOT NULL,
[TriggerId] [uniqueidentifier] NOT NULL,
[NotificationTypeId] [int] NOT NULL,
[Header] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Body] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Disabled] [bit] NOT NULL CONSTRAINT [DF__TAN_Notif__Disab__155BE6C7] DEFAULT ((0)),
[Archived] [bit] NOT NULL CONSTRAINT [DF__TAN_Notif__Archi__16500B00] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF__TAN_Notif__LastO__17442F39] DEFAULT (getdate()),
[Count] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_NotificationTemplate] ADD CONSTRAINT [PK_TAN_NotificationTemplate_1] PRIMARY KEY CLUSTERED  ([NotificationTemplateId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_NotificationTemplate] WITH NOCHECK ADD CONSTRAINT [FK_TAN_NotificationTemplate_NotificationTypeId] FOREIGN KEY ([NotificationTypeId]) REFERENCES [dbo].[TAN_NotificationType] ([NotificationTypeId])
GO
ALTER TABLE [dbo].[TAN_NotificationTemplate] WITH NOCHECK ADD CONSTRAINT [FK_TAN_NotificationTemplate_TriggerId] FOREIGN KEY ([TriggerId]) REFERENCES [dbo].[TAN_Trigger] ([TriggerId])
GO
