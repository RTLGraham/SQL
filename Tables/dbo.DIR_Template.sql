CREATE TABLE [dbo].[DIR_Template]
(
[TemplateId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncidentFieldId] [int] NULL,
[CustomerTemplateId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DIR_Template] ADD CONSTRAINT [PK_DIR_Template] PRIMARY KEY CLUSTERED  ([TemplateId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DIR_Template] ADD CONSTRAINT [FK_DIR_Template_CustomerTemplate] FOREIGN KEY ([CustomerTemplateId]) REFERENCES [dbo].[DIR_CustomerTemplate] ([CustomerTemplateId])
GO
ALTER TABLE [dbo].[DIR_Template] ADD CONSTRAINT [FK_DIR_Template_IncidentField] FOREIGN KEY ([IncidentFieldId]) REFERENCES [dbo].[DIR_IncidentField] ([IncidentFieldID])
GO
