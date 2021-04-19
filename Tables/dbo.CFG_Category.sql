CREATE TABLE [dbo].[CFG_Category]
(
[CategoryId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_CFG_Category_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CFG_Category_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CFG_Category] ADD CONSTRAINT [PK_CFG_Category] PRIMARY KEY CLUSTERED  ([CategoryId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
