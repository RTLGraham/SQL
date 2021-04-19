CREATE TABLE [dbo].[MSG_ChatroomParticipantMessage]
(
[ChatroomParticipantMessageId] [int] NOT NULL IDENTITY(1, 1),
[ChatroomParticipantId] [int] NOT NULL,
[MessageId] [int] NOT NULL,
[TimeReceived] [datetime] NULL,
[TimeRead] [datetime] NULL,
[Archived] [bit] NULL CONSTRAINT [DF_MSG_ChatroomParticipantMessage_Archived] DEFAULT ((0)),
[LastModified] [datetime] NULL CONSTRAINT [DF_MSG_ChatroomParticipantMessage_LastModified] DEFAULT (getdate()),
[LastUpdateId] [int] NULL,
[VehicleModeId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MSG_ChatroomParticipantMessage] ADD CONSTRAINT [PK_MSG_ChatroomParticipantMessage] PRIMARY KEY CLUSTERED  ([ChatroomParticipantMessageId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MSG_ChatroomParticipantMessage] ADD CONSTRAINT [FK_MSG_ChatroomParticipantMessage_ChatroomParticipant] FOREIGN KEY ([ChatroomParticipantId]) REFERENCES [dbo].[MSG_ChatroomParticipant] ([ChatroomParticipantId])
GO
ALTER TABLE [dbo].[MSG_ChatroomParticipantMessage] ADD CONSTRAINT [FK_MSG_ChatroomParticipantMessage_Message] FOREIGN KEY ([MessageId]) REFERENCES [dbo].[MSG_Message] ([MessageId])
GO
