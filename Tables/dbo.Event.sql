CREATE TABLE [dbo].[Event]
(
[EventId] [bigint] NOT NULL,
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[CreationCodeId] [smallint] NULL,
[Long] [float] NULL,
[Lat] [float] NULL,
[Heading] [smallint] NULL,
[Speed] [smallint] NULL,
[OdoGPS] [int] NULL,
[OdoRoadSpeed] [int] NULL,
[OdoDashboard] [int] NULL,
[EventDateTime] [datetime] NOT NULL,
[DigitalIO] [tinyint] NULL,
[CustomerIntId] [int] NOT NULL,
[AnalogData0] [smallint] NULL,
[AnalogData1] [smallint] NULL,
[AnalogData2] [smallint] NULL,
[AnalogData3] [smallint] NULL,
[AnalogData4] [smallint] NULL,
[AnalogData5] [smallint] NULL,
[SeqNumber] [int] NULL,
[SpeedLimit] [tinyint] NULL,
[LastOperation] [smalldatetime] NULL,
[Archived] [bit] NULL,
[Altitude] [smallint] NULL,
[GPSSatelliteCount] [tinyint] NULL,
[GPRSSignalStrength] [tinyint] NULL,
[SystemStatus] [tinyint] NULL,
[BatteryChargeLevel] [tinyint] NULL,
[ExternalInputVoltage] [tinyint] NULL,
[MaxSpeed] [tinyint] NULL,
[TripDistance] [int] NULL,
[TachoStatus] [tinyint] NULL,
[CANStatus] [tinyint] NULL,
[FuelLevel] [tinyint] NULL,
[HardwareStatus] [tinyint] NULL,
[ADBlueLevel] [tinyint] NULL,
[Spare] [tinyint] NULL,
[Bitmask] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Event] ADD CONSTRAINT [PK_Event] PRIMARY KEY CLUSTERED  ([EventId]) WITH (FILLFACTOR=100, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Event_Driver_EventDateTime] ON [dbo].[Event] ([DriverIntId], [EventDateTime]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Event_EventDateTime] ON [dbo].[Event] ([EventDateTime]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Event_Vehicle_CreationCode_EventDateTime] ON [dbo].[Event] ([VehicleIntId], [CreationCodeId], [EventDateTime]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Event_Vehicle_Driver_EventDateTime] ON [dbo].[Event] ([VehicleIntId], [DriverIntId], [EventDateTime]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Event_Vehicle_EventDateTime] ON [dbo].[Event] ([VehicleIntId], [EventDateTime]) INCLUDE ([Speed], [SpeedLimit]) ON [PRIMARY]
GO
