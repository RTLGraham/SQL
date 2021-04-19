CREATE TABLE [dbo].[MSG_ChatroomParticipant]
(
[ChatroomParticipantId] [int] NOT NULL IDENTITY(1, 1),
[ChatroomId] [int] NOT NULL,
[ParticipantId] [uniqueidentifier] NOT NULL,
[LastRequestedId] [int] NULL,
[Archived] [bit] NULL CONSTRAINT [DF_MSG_ChatroomParticipant_Archived] DEFAULT ((0)),
[LastModified] [datetime] NULL CONSTRAINT [DF_MSG_ChatroomParticipant_LastModified] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MSG_ChatroomParticipant] ADD CONSTRAINT [PK_MSG_ChatroomParticipant] PRIMARY KEY CLUSTERED  ([ChatroomParticipantId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MSG_ChatroomParticipant] ADD CONSTRAINT [FK_MSG_ChatroomParticipant_ChatroomId] FOREIGN KEY ([ChatroomId]) REFERENCES [dbo].[MSG_Chatroom] ([ChatroomId])
GO
