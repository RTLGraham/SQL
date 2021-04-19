CREATE TABLE [dbo].[UserDashboardTemplate]
(
[UserDashboardTemplateID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [uniqueidentifier] NOT NULL,
[DashboardControlID] [int] NOT NULL,
[Position] [int] NOT NULL CONSTRAINT [DF_UserDashboardTemplate_Position] DEFAULT ((1)),
[DateRangeEnum] [int] NOT NULL,
[ByVehicle] [bit] NOT NULL CONSTRAINT [DF_UserDashboardTemplate_ByVehicle] DEFAULT ((0)),
[ByDriver] [bit] NOT NULL CONSTRAINT [DF_UserDashboardTemplate_ByDriver] DEFAULT ((0)),
[VehicleModeDrive] [bit] NOT NULL CONSTRAINT [DF_UserDashboardTemplate_VehicleModeDrive] DEFAULT ((0)),
[VehicleModeIdle] [bit] NOT NULL CONSTRAINT [DF_UserDashboardTemplate_VehicleModeIdle] DEFAULT ((0)),
[VehicleModePTO] [bit] NOT NULL CONSTRAINT [DF_UserDashboardTemplate_VehicleModePTO] DEFAULT ((0)),
[VehicleModeKeyOn] [bit] NOT NULL CONSTRAINT [DF_UserDashboardTemplate_VehicleModeKeyOn] DEFAULT ((0)),
[VehicleModeKeyOff] [bit] NOT NULL CONSTRAINT [DF_UserDashboardTemplate_VehicleModeKeyOff] DEFAULT ((0)),
[RouteID] [int] NULL,
[VehicleTypeID] [int] NULL,
[SelectedDigitalIOs] [int] NOT NULL CONSTRAINT [DF_UserDashboardTemplate_SelectedDigitalIOs] DEFAULT ((0)),
[Archived] [bit] NOT NULL CONSTRAINT [DF_UserDashboardTemplate_Archived] DEFAULT ((0)),
[LastModified] [datetime] NOT NULL CONSTRAINT [DF_UserDashboardTemplate_LastModified] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserDashboardTemplate] ADD CONSTRAINT [PK_UserDashboardTemplate] PRIMARY KEY CLUSTERED  ([UserDashboardTemplateID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserDashboardTemplate] ADD CONSTRAINT [FK_UserDashboardTemplate_DashboardControlType] FOREIGN KEY ([DashboardControlID]) REFERENCES [dbo].[DashboardControlType] ([DashboardControlTypeID])
GO
ALTER TABLE [dbo].[UserDashboardTemplate] ADD CONSTRAINT [FK_UserDashboardTemplate_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User] ([UserID])
GO
