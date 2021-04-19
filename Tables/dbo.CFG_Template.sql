CREATE TABLE [dbo].[CFG_Template]
(
[TemplateId] [int] NOT NULL IDENTITY(1, 1),
[CustomerIntId] [int] NULL,
[CategoryId] [int] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_CFG_Template_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CFG_Template_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CFG_Template] ADD CONSTRAINT [PK_CFG_Template] PRIMARY KEY CLUSTERED  ([TemplateId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CFG_Template] ADD CONSTRAINT [FK_CFG_Template_CFG_Category] FOREIGN KEY ([CategoryId]) REFERENCES [dbo].[CFG_Category] ([CategoryId])
GO
ALTER TABLE [dbo].[CFG_Template] ADD CONSTRAINT [FK_CFG_Template_Customer] FOREIGN KEY ([CustomerIntId]) REFERENCES [dbo].[Customer] ([CustomerIntId])
GO
