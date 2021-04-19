CREATE TABLE [dbo].[LanguageCulture]
(
[LanguageCultureID] [smallint] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Code] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HardwareIndex] [smallint] NULL,
[Archived] [bit] NULL CONSTRAINT [DF_LanguageCulture_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LanguageCulture] ADD CONSTRAINT [PK_LanguageCulture] PRIMARY KEY CLUSTERED  ([LanguageCultureID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LanguageCulture] ADD CONSTRAINT [uc_LanguageCulture_Name] UNIQUE NONCLUSTERED  ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
