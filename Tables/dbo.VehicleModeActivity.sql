CREATE TABLE [dbo].[VehicleModeActivity]
(
[VehicleIntId] [int] NULL,
[VehicleModeId] [int] NULL,
[StartDate] [datetime] NULL,
[StartEventId] [bigint] NULL,
[StartLat] [float] NULL,
[StartLon] [float] NULL,
[StartDriverIntId] [int] NULL,
[EndDate] [datetime] NULL,
[EndEventId] [bigint] NULL,
[EndLat] [float] NULL,
[EndLon] [float] NULL,
[EndDriverIntId] [int] NULL,
[LatestEventDateTime] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VehicleModeActivity_DriverEndMode] ON [dbo].[VehicleModeActivity] ([StartDriverIntId], [EndDate], [VehicleModeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VehicleModeActivity_VehicleEndMode] ON [dbo].[VehicleModeActivity] ([VehicleIntId], [EndDate], [VehicleModeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VehicleModeActivity_VehicleStartEnd] ON [dbo].[VehicleModeActivity] ([VehicleIntId], [StartDate], [EndDate]) INCLUDE ([StartDriverIntId]) ON [PRIMARY]
GO
