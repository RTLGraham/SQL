CREATE TABLE [dbo].[LEO_ApplicationConfiguration]
(
[ApplicationConfigurationId] [int] NOT NULL IDENTITY(1, 1),
[ApplicationId] [int] NOT NULL,
[ConfigurationId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_ApplicationConfiguration] ADD CONSTRAINT [PK_LEO_ApplicationConfiguration] PRIMARY KEY CLUSTERED  ([ApplicationConfigurationId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_ApplicationConfiguration] ADD CONSTRAINT [FK_LEO_ApplicationConfiguration_Application] FOREIGN KEY ([ApplicationId]) REFERENCES [dbo].[LEO_Application] ([ApplicationId])
GO
ALTER TABLE [dbo].[LEO_ApplicationConfiguration] ADD CONSTRAINT [FK_LEO_ApplicationConfiguration_Configuration] FOREIGN KEY ([ConfigurationId]) REFERENCES [dbo].[LEO_Configuration] ([ConfigurationId])
GO
