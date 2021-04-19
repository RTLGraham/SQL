CREATE TABLE [dbo].[SiteType]
(
[SiteTypeId] [int] NOT NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_SiteType_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SiteType] ADD CONSTRAINT [PK_SiteType] PRIMARY KEY CLUSTERED  ([SiteTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
