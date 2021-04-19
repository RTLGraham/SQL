CREATE TABLE [dbo].[TachoMode]
(
[TachoModeID] [int] NOT NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TachoMode] ADD CONSTRAINT [PK_TachoMode] PRIMARY KEY CLUSTERED  ([TachoModeID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TachoName] ON [dbo].[TachoMode] ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
