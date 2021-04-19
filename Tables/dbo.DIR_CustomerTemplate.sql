CREATE TABLE [dbo].[DIR_CustomerTemplate]
(
[CustomerTemplateId] [int] NOT NULL IDENTITY(1, 1),
[CustomerIntId] [int] NULL,
[IncidentTypeId] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DIR_CustomerTemplate] ADD CONSTRAINT [PK_DIR_CustomerTemplate] PRIMARY KEY CLUSTERED  ([CustomerTemplateId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DIR_CustomerTemplate] ADD CONSTRAINT [FK_DIR_CustomerTemplate_Customer] FOREIGN KEY ([CustomerIntId]) REFERENCES [dbo].[Customer] ([CustomerIntId])
GO
ALTER TABLE [dbo].[DIR_CustomerTemplate] ADD CONSTRAINT [FK_DIR_CustomerTemplate_IncidentType] FOREIGN KEY ([IncidentTypeId]) REFERENCES [dbo].[DIR_IncidentType] ([IncidentTypeId])
GO
