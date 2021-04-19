CREATE TABLE [dbo].[TAN_GeofenceEvent]
(
[GeofenceEventId] [bigint] NOT NULL IDENTITY(1, 1),
[EventId] [bigint] NULL,
[CustomerId] [uniqueidentifier] NOT NULL,
[VehicleIntID] [int] NULL,
[DriverIntId] [int] NULL,
[EventDateTime] [datetime] NULL,
[ProcessInd] [smallint] NOT NULL CONSTRAINT [DF_GeofenceEvent_ProcessInd] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_GeofenceEvent_LastOperation] DEFAULT (getdate()),
[GeofenceId] [uniqueidentifier] NULL,
[Lat] [float] NULL,
[Long] [float] NULL,
[Heading] [smallint] NULL,
[Speed] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_GeofenceEvent] ADD CONSTRAINT [PK_TAN_GeofenceEvent] PRIMARY KEY CLUSTERED  ([GeofenceEventId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TAN_GeofenceEvent_EventId] ON [dbo].[TAN_GeofenceEvent] ([EventId]) INCLUDE ([GeofenceId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
