CREATE TABLE [dbo].[VehicleMaintenanceSchedule]
(
[VehicleMaintenanceScheduleID] [int] NOT NULL IDENTITY(1, 1),
[VehicleIntID] [int] NOT NULL,
[VehicleMaintenanceTypeID] [int] NOT NULL,
[DistanceInterval] [int] NULL,
[TimeInterval] [int] NULL,
[FuelInterval] [int] NULL,
[OdoAtLastMaintenance] [int] NULL,
[DateOfLastMaintenance] [smalldatetime] NULL,
[FuelAtLastMaintenance] [int] NULL,
[EngineInterval] [int] NULL,
[EngineAtLastMaintenance] [int] NULL,
[TimeIntervalWeeks] [int] NULL,
[ReminderDays] [smallint] NOT NULL CONSTRAINT [DF__VehicleMa__Remin__3B2C89F4] DEFAULT ((7)),
[LastReminderDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleMaintenanceSchedule] ADD CONSTRAINT [PK__VehicleMaintenan__7A9D0393] PRIMARY KEY NONCLUSTERED  ([VehicleMaintenanceScheduleID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_VehicleMaintenanceSchedule] ON [dbo].[VehicleMaintenanceSchedule] ([VehicleIntID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_VehicleMaintenanceSchedule] ON [dbo].[VehicleMaintenanceSchedule] ([VehicleIntID], [VehicleMaintenanceTypeID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
