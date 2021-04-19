CREATE TABLE [dbo].[CFG_TemplateKey]
(
[TemplateKeyId] [int] NOT NULL IDENTITY(1, 1),
[TemplateId] [int] NOT NULL,
[KeyId] [int] NOT NULL,
[KeyValue] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CFG_TemplateKey] ADD CONSTRAINT [PK_CFG_TemplateKey] PRIMARY KEY CLUSTERED  ([TemplateKeyId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CFG_TemplateKey] ADD CONSTRAINT [FK_CFG_TemplateKey_Key] FOREIGN KEY ([KeyId]) REFERENCES [dbo].[CFG_Key] ([KeyId])
GO
