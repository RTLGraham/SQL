CREATE TABLE [dbo].[ReleaseNote]
(
[ReleaseNoteId] [int] NOT NULL IDENTITY(1, 1),
[AssemblyVersion] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReleaseDate] [datetime] NOT NULL,
[FileExtension] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FilePayload] [image] NULL,
[LastOperation] [datetime] NULL,
[Archived] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReleaseNote] ADD CONSTRAINT [PK_ReleaseNote] PRIMARY KEY CLUSTERED  ([ReleaseNoteId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
