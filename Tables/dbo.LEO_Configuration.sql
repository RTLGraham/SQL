CREATE TABLE [dbo].[LEO_Configuration]
(
[ConfigurationId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF__LEO_Confi__Archi__6A7C75BA] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF__LEO_Confi__LastO__6B7099F3] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_Configuration] ADD CONSTRAINT [PK_LEO_Configuration] PRIMARY KEY CLUSTERED  ([ConfigurationId]) ON [PRIMARY]
GO
