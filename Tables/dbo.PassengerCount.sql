CREATE TABLE [dbo].[PassengerCount]
(
[PassengerCountId] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleId] [uniqueidentifier] NOT NULL,
[DriverId] [uniqueidentifier] NOT NULL,
[StopLat] [float] NULL,
[StopLon] [float] NULL,
[OdoGPS] [int] NULL,
[OdoDashboard] [int] NULL,
[DoorsOpenDateTime] [datetime] NOT NULL,
[DoorsClosedDateTime] [datetime] NOT NULL,
[StartPassengerCount] [int] NULL,
[EndPassengerCount] [int] NULL,
[DeltaInDoor1] [int] NULL,
[DeltaOutDoor1] [int] NULL,
[DeltaInDoor2] [int] NULL,
[DeltaOutDoor2] [int] NULL,
[DeltaInDoor3] [int] NULL,
[DeltaOutDoor3] [int] NULL,
[AbsoluteInDoor1] [int] NULL,
[AbsoluteOutDoor1] [int] NULL,
[AbsoluteInDoor2] [int] NULL,
[AbsoluteOutDoor2] [int] NULL,
[AbsoluteInDoor3] [int] NULL,
[AbsoluteOutDoor3] [int] NULL,
[CalibrationFlag] [smallint] NULL,
[LastOperation] [datetime] NULL,
[GeofenceId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PassengerCount] ADD CONSTRAINT [PK_PassengerCount] PRIMARY KEY CLUSTERED  ([PassengerCountId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PassengerCount] WITH NOCHECK ADD CONSTRAINT [FK_PassengerCount_DriverId] FOREIGN KEY ([DriverId]) REFERENCES [dbo].[Driver] ([DriverId])
GO
ALTER TABLE [dbo].[PassengerCount] WITH NOCHECK ADD CONSTRAINT [FK_PassengerCount_VehicleId] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
