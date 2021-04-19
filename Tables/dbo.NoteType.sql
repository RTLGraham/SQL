CREATE TABLE [dbo].[NoteType]
(
[NoteTypeId] [int] NOT NULL,
[NoteTypeName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NoteTypeDescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_NoteType_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_NoteType_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NoteType] ADD CONSTRAINT [PK_NoteType] PRIMARY KEY CLUSTERED  ([NoteTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_NoteTypeName] ON [dbo].[NoteType] ([NoteTypeName]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
