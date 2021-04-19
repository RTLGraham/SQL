CREATE TABLE [dbo].[LEO_ConfigurationSetting]
(
[ConfigurationSettingId] [int] NOT NULL IDENTITY(1, 1),
[ApplicationConfigurationFileId] [int] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastOperation] [smalldatetime] NOT NULL CONSTRAINT [DF__LEO_Confi__LastO__5A1103C7] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF__LEO_Confi__Archi__5B052800] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_ConfigurationSetting] ADD CONSTRAINT [PK_LEO_ConfigurationSetting] PRIMARY KEY CLUSTERED  ([ConfigurationSettingId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_ConfigurationSetting] ADD CONSTRAINT [FK_LEO_ConfigurationSetting_LeopardAppConfig] FOREIGN KEY ([ApplicationConfigurationFileId]) REFERENCES [dbo].[LEO_ApplicationConfigurationFile] ([ApplicationConfigurationFileId])
GO
