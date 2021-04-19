CREATE TABLE [dbo].[UserDashboardControlConfig]
(
[UserID] [uniqueidentifier] NOT NULL,
[DashboardControl1ID] [int] NULL,
[DashboardControl2ID] [int] NULL,
[DashboardControl3ID] [int] NULL,
[DashboardControl4ID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserDashboardControlConfig] ADD CONSTRAINT [PK_UserDashboardControlConfig] PRIMARY KEY CLUSTERED  ([UserID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserDashboardControlConfig] ADD CONSTRAINT [FK_UserDashboardControlConfig_DashboardControl1Type] FOREIGN KEY ([DashboardControl1ID]) REFERENCES [dbo].[DashboardControlType] ([DashboardControlTypeID])
GO
ALTER TABLE [dbo].[UserDashboardControlConfig] ADD CONSTRAINT [FK_UserDashboardControlConfig_DashboardControl2Type] FOREIGN KEY ([DashboardControl2ID]) REFERENCES [dbo].[DashboardControlType] ([DashboardControlTypeID])
GO
ALTER TABLE [dbo].[UserDashboardControlConfig] ADD CONSTRAINT [FK_UserDashboardControlConfig_DashboardControl3Type] FOREIGN KEY ([DashboardControl3ID]) REFERENCES [dbo].[DashboardControlType] ([DashboardControlTypeID])
GO
ALTER TABLE [dbo].[UserDashboardControlConfig] ADD CONSTRAINT [FK_UserDashboardControlConfig_DashboardControl4Type] FOREIGN KEY ([DashboardControl4ID]) REFERENCES [dbo].[DashboardControlType] ([DashboardControlTypeID])
GO
ALTER TABLE [dbo].[UserDashboardControlConfig] ADD CONSTRAINT [FK_UserDashboardControlConfig_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User] ([UserID])
GO
