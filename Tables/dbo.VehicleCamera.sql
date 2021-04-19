CREATE TABLE [dbo].[VehicleCamera]
(
[VehicleId] [uniqueidentifier] NOT NULL,
[CameraId] [uniqueidentifier] NOT NULL,
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_VehicleCamera_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_VehicleCamera_Archived] DEFAULT ((0)),
[VehicleCameraID] [uniqueidentifier] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleCamera] ADD CONSTRAINT [PK_VehicleCamera_VehicleCameraID] PRIMARY KEY CLUSTERED  ([VehicleCameraID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleCamera] ADD CONSTRAINT [FK_VehicleCamera_Camera] FOREIGN KEY ([CameraId]) REFERENCES [dbo].[Camera] ([CameraId])
GO
ALTER TABLE [dbo].[VehicleCamera] ADD CONSTRAINT [FK_VehicleCamera_Vehicle] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
