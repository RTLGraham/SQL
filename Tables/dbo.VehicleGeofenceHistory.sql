CREATE TABLE [dbo].[VehicleGeofenceHistory]
(
[VehicleGeofenceHistoryId] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NOT NULL,
[GeofenceId] [uniqueidentifier] NULL,
[EntryDateTime] [datetime] NOT NULL,
[EntryDriverIntId] [int] NULL,
[ExitDateTime] [datetime] NULL,
[ExitDriverIntId] [int] NULL,
[LastOperation] [smalldatetime] NOT NULL CONSTRAINT [DF_VehicleGeofenceHistory_LastOperation] DEFAULT (getdate()),
[EntryEventId] [bigint] NULL,
[ExitEventId] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleGeofenceHistory] ADD CONSTRAINT [PK_VehicleGeofenceHistory] PRIMARY KEY CLUSTERED  ([VehicleGeofenceHistoryId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VehicleGeofenceHistory_EntryExitTime] ON [dbo].[VehicleGeofenceHistory] ([EntryDateTime], [ExitDateTime]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VehicleGeofenceHistory_Vehicle_ExitDate] ON [dbo].[VehicleGeofenceHistory] ([VehicleIntId], [ExitDateTime]) INCLUDE ([GeofenceId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VehicleGeofenceHistory_VehicleGeofenceEntryExit] ON [dbo].[VehicleGeofenceHistory] ([VehicleIntId], [GeofenceId], [EntryDateTime], [ExitDateTime]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VehicleGeofenceHistory_VehicleGeofenceExit] ON [dbo].[VehicleGeofenceHistory] ([VehicleIntId], [GeofenceId], [ExitDateTime]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
