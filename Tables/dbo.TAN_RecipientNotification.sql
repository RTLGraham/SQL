CREATE TABLE [dbo].[TAN_RecipientNotification]
(
[NotificationTemplateId] [uniqueidentifier] NOT NULL,
[RecipientName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecipientAddress] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Disabled] [bit] NOT NULL CONSTRAINT [DF__TAN_Recip__Disab__1DF12CC8] DEFAULT ((0)),
[Archived] [bit] NOT NULL CONSTRAINT [DF__TAN_Recip__Archi__1EE55101] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF__TAN_Recip__LastO__1FD9753A] DEFAULT (getdate()),
[Count] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_RecipientNotification] ADD CONSTRAINT [PK_TAN_RecipientNotification_1] PRIMARY KEY CLUSTERED  ([NotificationTemplateId], [RecipientName]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_RecipientNotification] WITH NOCHECK ADD CONSTRAINT [FK_TAN_RecipientNotification_NotificationTemplateId] FOREIGN KEY ([NotificationTemplateId]) REFERENCES [dbo].[TAN_NotificationTemplate] ([NotificationTemplateId])
GO
