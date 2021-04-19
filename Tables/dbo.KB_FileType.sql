CREATE TABLE [dbo].[KB_FileType]
(
[FileTypeId] [smallint] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_FileType] ADD CONSTRAINT [PK_KB_FileTypeId] PRIMARY KEY CLUSTERED  ([FileTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
