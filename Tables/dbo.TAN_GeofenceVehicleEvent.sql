CREATE TABLE [dbo].[TAN_GeofenceVehicleEvent]
(
[GeofenceVehicleEventId] [bigint] NOT NULL IDENTITY(1, 1),
[EventId] [bigint] NULL,
[CustomerId] [uniqueidentifier] NOT NULL,
[VehicleIntID] [int] NULL,
[DriverIntId] [int] NULL,
[EventDateTime] [datetime] NULL,
[ProcessInd] [smallint] NOT NULL CONSTRAINT [DF_GeofenceVehicleEvent_ProcessInd] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_GeofenceVehicleEvent_LastOperation] DEFAULT (getdate()),
[GeofenceId] [uniqueidentifier] NULL,
[Lat] [float] NULL,
[Long] [float] NULL,
[Heading] [smallint] NULL,
[Speed] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_GeofenceVehicleEvent] ADD CONSTRAINT [PK_TAN_GeofenceVehicleEvent] PRIMARY KEY CLUSTERED  ([GeofenceVehicleEventId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TAN_GeofenceVehicleEvent_EventId] ON [dbo].[TAN_GeofenceVehicleEvent] ([EventId]) INCLUDE ([GeofenceId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
