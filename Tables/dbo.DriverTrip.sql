CREATE TABLE [dbo].[DriverTrip]
(
[DriverTripId] [bigint] NOT NULL IDENTITY(1, 1),
[DriverIntId] [int] NOT NULL,
[VehicleIntId] [int] NOT NULL,
[StartEventDateTime] [datetime] NOT NULL,
[StartEventID] [bigint] NOT NULL,
[StartLat] [float] NULL,
[StartLong] [float] NULL,
[StartOdo] [int] NULL,
[EndEventDateTime] [datetime] NOT NULL,
[EndEventID] [bigint] NULL,
[EndLat] [float] NULL,
[EndLong] [float] NULL,
[EndOdo] [int] NULL,
[TripDistance] [int] NULL,
[TripDuration] [int] NULL,
[IsBusiness] [bit] NOT NULL CONSTRAINT [DF_DriverTrip_IsBusiness] DEFAULT ((0)),
[Comment] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_DriverTrip_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_DriverTrip_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DriverTrip] ADD CONSTRAINT [PK_DriverTrip] PRIMARY KEY CLUSTERED  ([DriverTripId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DriverTrip_DriverDate] ON [dbo].[DriverTrip] ([DriverIntId], [StartEventDateTime]) INCLUDE ([Archived], [VehicleIntId], [StartOdo], [EndOdo], [TripDistance]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DriverTrip_DriverStartEvent] ON [dbo].[DriverTrip] ([DriverIntId], [StartEventID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DriverTrip_StartEnd] ON [dbo].[DriverTrip] ([StartEventDateTime], [EndEventDateTime]) INCLUDE ([DriverIntId], [VehicleIntId], [StartLat], [StartLong], [EndLat], [EndLong]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DriverTrip_VehicleDate] ON [dbo].[DriverTrip] ([VehicleIntId], [StartEventDateTime]) INCLUDE ([Archived], [DriverIntId], [StartOdo], [EndOdo], [TripDistance]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
