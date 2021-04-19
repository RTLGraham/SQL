CREATE TABLE [dbo].[SiteImportStatus]
(
[SiteImportStatusId] [smallint] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF__SiteImportStatus__Archi__78BFA819] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF__SiteImportStatus__LastO__79B3CC52] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SiteImportStatus] ADD CONSTRAINT [PK_SiteImportStatus] PRIMARY KEY CLUSTERED  ([SiteImportStatusId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
