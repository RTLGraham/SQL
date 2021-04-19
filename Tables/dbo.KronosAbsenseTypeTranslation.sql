CREATE TABLE [dbo].[KronosAbsenseTypeTranslation]
(
[KronosAbsenseTypeTranslationId] [int] NOT NULL IDENTITY(1, 1),
[KronosAbsenseTypeId] [int] NOT NULL,
[LanguageCulture] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayDescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_KronosAbsenseTypeTranslation_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_KronosAbsenseTypeTranslation_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KronosAbsenseTypeTranslation] ADD CONSTRAINT [PK_KronosAbsenseTypeTranslation] PRIMARY KEY CLUSTERED  ([KronosAbsenseTypeTranslationId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KronosAbsenseTypeTranslation] ADD CONSTRAINT [FK_KronosAbsenseTypeTranslation_KronosAbsenseType] FOREIGN KEY ([KronosAbsenseTypeId]) REFERENCES [dbo].[KronosAbsenseType] ([KronosAbsenseTypeId])
GO
