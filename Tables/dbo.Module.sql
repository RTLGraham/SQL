CREATE TABLE [dbo].[Module]
(
[ModuleID] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Reference] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Module_Reference] DEFAULT (''),
[Archived] [bit] NOT NULL CONSTRAINT [DF__Module__Archived__65039386] DEFAULT ((0)),
[ModuleCategoryID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Module] ADD CONSTRAINT [PK_Module] PRIMARY KEY CLUSTERED  ([ModuleID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Module] ADD CONSTRAINT [FK_Module_ModuleCategory] FOREIGN KEY ([ModuleCategoryID]) REFERENCES [dbo].[ModuleCategory] ([ModuleCategoryID])
GO
