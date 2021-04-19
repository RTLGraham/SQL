CREATE TABLE [dbo].[CAM_TagTranslation]
(
[TagTranslationId] [int] NOT NULL IDENTITY(1, 1),
[TagId] [int] NOT NULL,
[LanguageCulture] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayDescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_CAM_TagTranslation_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_CAM_TagTranslation_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_TagTranslation] ADD CONSTRAINT [PK_CAM_TagTranslation] PRIMARY KEY CLUSTERED  ([TagTranslationId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_TagTranslation] ADD CONSTRAINT [FK_CAM_TagTranslation_CAM_Tag] FOREIGN KEY ([TagId]) REFERENCES [dbo].[CAM_Tag] ([TagId])
GO
