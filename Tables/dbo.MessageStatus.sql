CREATE TABLE [dbo].[MessageStatus]
(
[MessageStatusId] [int] NOT NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_MessageStatus_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageStatus] ADD CONSTRAINT [PK_MessageStatus] PRIMARY KEY CLUSTERED  ([MessageStatusId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MessageStatus] ON [dbo].[MessageStatus] ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
