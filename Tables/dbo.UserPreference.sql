CREATE TABLE [dbo].[UserPreference]
(
[UserPreferenceID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_UserPreference_UserPreferenceID] DEFAULT (newid()),
[UserID] [uniqueidentifier] NULL,
[NameID] [int] NOT NULL,
[Value] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Archived] [bit] NULL CONSTRAINT [DF_UserPreference_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserPreference] ADD CONSTRAINT [PK_UserPreference] PRIMARY KEY CLUSTERED  ([UserPreferenceID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UserPreference_NameUser] ON [dbo].[UserPreference] ([NameID], [UserID]) INCLUDE ([Value]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserPreference] ADD CONSTRAINT [FK_UserPreference_DictionaryName] FOREIGN KEY ([NameID]) REFERENCES [dbo].[DictionaryName] ([NameID])
GO
ALTER TABLE [dbo].[UserPreference] ADD CONSTRAINT [FK_UserPreference_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User] ([UserID])
GO
