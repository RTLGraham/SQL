CREATE TABLE [dbo].[LEO_ApplicationConfigurationFile]
(
[ApplicationConfigurationFileId] [int] NOT NULL IDENTITY(1, 1),
[LeopardId] [int] NOT NULL,
[ApplicationConfigurationId] [int] NOT NULL,
[Timestamp] [datetime] NULL,
[Size] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_ApplicationConfigurationFile] ADD CONSTRAINT [PK_LEO_ApplicationConfigurationFile] PRIMARY KEY CLUSTERED  ([ApplicationConfigurationFileId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_ApplicationConfigurationFile] ADD CONSTRAINT [FK_LEO_ApplicationConfigurationFile_ApplicationConfiguration] FOREIGN KEY ([ApplicationConfigurationId]) REFERENCES [dbo].[LEO_ApplicationConfiguration] ([ApplicationConfigurationId])
GO
ALTER TABLE [dbo].[LEO_ApplicationConfigurationFile] ADD CONSTRAINT [FK_LEO_ApplicationConfigurationFile_Leopard] FOREIGN KEY ([LeopardId]) REFERENCES [dbo].[LEO_Leopard] ([LeopardId])
GO
