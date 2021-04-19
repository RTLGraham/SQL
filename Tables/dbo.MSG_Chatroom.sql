CREATE TABLE [dbo].[MSG_Chatroom]
(
[ChatroomId] [int] NOT NULL IDENTITY(1, 1),
[OwnerId] [uniqueidentifier] NOT NULL,
[ChatroomName] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_MSG_Chatroom_Archived] DEFAULT ((0)),
[LastModified] [datetime] NULL CONSTRAINT [DF_MSG_Chatroom_LastModified] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MSG_Chatroom] ADD CONSTRAINT [PK_MSG_Chatroom] PRIMARY KEY CLUSTERED  ([ChatroomId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
