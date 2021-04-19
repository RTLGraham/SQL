CREATE TABLE [dbo].[CustomerPreference]
(
[CustomerPreferenceID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_CustomerPreference_CustomerPreferenceID] DEFAULT (newid()),
[CustomerID] [uniqueidentifier] NULL,
[NameID] [int] NOT NULL,
[Value] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Archived] [bit] NULL CONSTRAINT [DF_CustomerPreference_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomerPreference] ADD CONSTRAINT [PK_CustomerPreference] PRIMARY KEY CLUSTERED  ([CustomerPreferenceID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CustomerPreference_NameID] ON [dbo].[CustomerPreference] ([NameID]) INCLUDE ([CustomerID], [Value]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomerPreference] ADD CONSTRAINT [FK_CustomerPreference_DictionaryName] FOREIGN KEY ([NameID]) REFERENCES [dbo].[DictionaryName] ([NameID])
GO
