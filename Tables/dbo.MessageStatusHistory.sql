CREATE TABLE [dbo].[MessageStatusHistory]
(
[MessageStatusHistoryId] [int] NOT NULL IDENTITY(1, 1),
[MessageId] [int] NULL,
[MessageStatusId] [int] NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_MessageStatusHistory_LastModified] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageStatusHistory] ADD CONSTRAINT [PK_MessageStatusHistory] PRIMARY KEY CLUSTERED  ([MessageStatusHistoryId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageStatusHistory] ADD CONSTRAINT [FK_MessageStatusHistory_MessageHistory] FOREIGN KEY ([MessageId]) REFERENCES [dbo].[MessageHistory] ([MessageId])
GO
ALTER TABLE [dbo].[MessageStatusHistory] ADD CONSTRAINT [FK_MessageStatusHistory_MessageStatus] FOREIGN KEY ([MessageStatusId]) REFERENCES [dbo].[MessageStatus] ([MessageStatusId])
GO
