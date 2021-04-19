CREATE TABLE [dbo].[MSG_Message]
(
[MessageId] [int] NOT NULL IDENTITY(1, 1),
[Messagetext] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MessageOwner] [uniqueidentifier] NOT NULL,
[TimeSent] [datetime] NOT NULL,
[Archived] [bit] NULL CONSTRAINT [DF_MSG_Message_Archived] DEFAULT ((0)),
[LastModified] [datetime] NULL CONSTRAINT [DF_MSG_Message_LastModified] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MSG_Message] ADD CONSTRAINT [PK_MSG_Message] PRIMARY KEY CLUSTERED  ([MessageId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
