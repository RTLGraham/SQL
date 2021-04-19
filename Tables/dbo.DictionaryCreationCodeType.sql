CREATE TABLE [dbo].[DictionaryCreationCodeType]
(
[DictionaryCreationCodeTypeId] [int] NOT NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_DictionaryCreationCodeType_Archived] DEFAULT ((0)),
[LastModified] [datetime] NULL CONSTRAINT [DF_DictionaryCreationCodeType_LastModified] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DictionaryCreationCodeType] ADD CONSTRAINT [PK_DictionaryCreationCodeType] PRIMARY KEY CLUSTERED  ([DictionaryCreationCodeTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DictionaryCreationCodeType] ON [dbo].[DictionaryCreationCodeType] ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
