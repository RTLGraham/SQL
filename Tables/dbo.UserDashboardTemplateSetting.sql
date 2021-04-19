CREATE TABLE [dbo].[UserDashboardTemplateSetting]
(
[UserDashboardTemplateSettingID] [int] NOT NULL IDENTITY(1, 1),
[UserDashboardTemplateID] [int] NOT NULL,
[SettingName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SettingValue] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_UserDashboardTemplateSetting_Archived] DEFAULT ((0)),
[LastModified] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserDashboardTemplateSetting] ADD CONSTRAINT [PK_UserDashboardTemplateSetting_1] PRIMARY KEY CLUSTERED  ([UserDashboardTemplateSettingID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserDashboardTemplateSetting] ADD CONSTRAINT [FK_UserDashboardTemplateSetting_UserDashboardTemplate] FOREIGN KEY ([UserDashboardTemplateID]) REFERENCES [dbo].[UserDashboardTemplate] ([UserDashboardTemplateID])
GO
