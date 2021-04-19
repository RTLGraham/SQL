CREATE TABLE [dbo].[Note]
(
[NoteId] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Note_NoteId] DEFAULT (newid()),
[NoteEntityId] [uniqueidentifier] NOT NULL,
[NoteTypeId] [int] NOT NULL,
[Note] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NoteDate] [datetime] NULL CONSTRAINT [DF_Note_NoteDate] DEFAULT (getdate()),
[LastModified] [datetime] NULL CONSTRAINT [DF_Note_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_Note_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Note] ADD CONSTRAINT [PK_Note] PRIMARY KEY CLUSTERED  ([NoteId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Note] ADD CONSTRAINT [FK_Note_NoteType] FOREIGN KEY ([NoteTypeId]) REFERENCES [dbo].[NoteType] ([NoteTypeId])
GO
