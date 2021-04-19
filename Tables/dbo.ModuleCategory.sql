CREATE TABLE [dbo].[ModuleCategory]
(
[ModuleCategoryID] [int] NOT NULL IDENTITY(1, 1),
[ModuleCategoryName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastOperation] [datetime] NOT NULL CONSTRAINT [DF__ModuleCat__LastO__65F7B7BF] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF__ModuleCat__Archi__66EBDBF8] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModuleCategory] ADD CONSTRAINT [PK__ModuleCa__3E745B71A8DA4019] PRIMARY KEY CLUSTERED  ([ModuleCategoryID]) ON [PRIMARY]
GO
