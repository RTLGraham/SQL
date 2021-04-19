CREATE TABLE [dbo].[TelcoProvider]
(
[TelcoProviderId] [int] NOT NULL,
[Name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_TelcoProvider_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TelcoProvider] ADD CONSTRAINT [PK_TelcoProvider] PRIMARY KEY CLUSTERED  ([TelcoProviderId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TelcoProviderName] ON [dbo].[TelcoProvider] ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
