CREATE TABLE [dbo].[UserNote]
(
[UserId] [uniqueidentifier] NOT NULL,
[NoteId] [uniqueidentifier] NOT NULL,
[Archived] [bit] NULL CONSTRAINT [DF_UserNote_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserNote] ADD CONSTRAINT [PK_UserNote] PRIMARY KEY CLUSTERED  ([UserId], [NoteId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserNote] ADD CONSTRAINT [FK_UserNote_Note] FOREIGN KEY ([NoteId]) REFERENCES [dbo].[Note] ([NoteId])
GO
ALTER TABLE [dbo].[UserNote] ADD CONSTRAINT [FK_UserNote_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserID])
GO
