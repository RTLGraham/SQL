CREATE TABLE [dbo].[DBConfig]
(
[DBConfigID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_DBConfig_DBConfigID] DEFAULT (newid()),
[NameID] [int] NOT NULL,
[Value] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Archived] [bit] NULL CONSTRAINT [DF_DBConfig_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DBConfig] ADD CONSTRAINT [PK_DBConfig] PRIMARY KEY CLUSTERED  ([DBConfigID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DBConfig] ADD CONSTRAINT [FK_DBConfig_DictionaryName] FOREIGN KEY ([NameID]) REFERENCES [dbo].[DictionaryName] ([NameID])
GO
