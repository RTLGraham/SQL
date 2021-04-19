CREATE TABLE [dbo].[DictionaryCreationCodes]
(
[CreationCodeId] [smallint] NOT NULL,
[DictionaryNameId] [int] NOT NULL,
[DictionaryCreationCodeTypeId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DictionaryCreationCodes] ADD CONSTRAINT [PK_DictionaryCreationCodes] PRIMARY KEY CLUSTERED  ([CreationCodeId], [DictionaryNameId], [DictionaryCreationCodeTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DictionaryCreationCodes] ADD CONSTRAINT [FK_DictionaryCreationCodes_DictionaryCreationCodeType] FOREIGN KEY ([DictionaryCreationCodeTypeId]) REFERENCES [dbo].[DictionaryCreationCodeType] ([DictionaryCreationCodeTypeId])
GO
ALTER TABLE [dbo].[DictionaryCreationCodes] ADD CONSTRAINT [FK_DictionaryCreationCodes_DictionaryName] FOREIGN KEY ([DictionaryNameId]) REFERENCES [dbo].[DictionaryName] ([NameID])
GO
