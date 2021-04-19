CREATE TABLE [dbo].[DictionaryName]
(
[NameID] [int] NOT NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_DictionaryName_Archived_1] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DictionaryName] ADD CONSTRAINT [PK_DictionaryName] PRIMARY KEY CLUSTERED  ([NameID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_DictionaryName] ON [dbo].[DictionaryName] ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
