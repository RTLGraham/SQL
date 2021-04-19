CREATE TABLE [dbo].[LEO_Temp_ConfigurationSetting]
(
[ConfigurationSettingId] [int] NOT NULL IDENTITY(1, 1),
[ApplicationConfigurationFileId] [int] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastOperation] [smalldatetime] NOT NULL CONSTRAINT [DF__LEO_Temp___LastO__554C4EAA] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF__LEO_Temp___Archi__564072E3] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_Temp_ConfigurationSetting] ADD CONSTRAINT [PK_LEO_Temp_ConfigurationSetting] PRIMARY KEY CLUSTERED  ([ConfigurationSettingId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_Temp_ConfigurationSetting] ADD CONSTRAINT [FK_LEO_Temp_ConfigurationSetting_LeopardAppConfig] FOREIGN KEY ([ApplicationConfigurationFileId]) REFERENCES [dbo].[LEO_ApplicationConfigurationFile] ([ApplicationConfigurationFileId])
GO
