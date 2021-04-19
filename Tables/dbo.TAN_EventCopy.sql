CREATE TABLE [dbo].[TAN_EventCopy]
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
[ADBlueLevel] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_EventCopy] ADD CONSTRAINT [PK_TAN_EventCopy] PRIMARY KEY CLUSTERED  ([EventId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON, STATISTICS_NORECOMPUTE=ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TAN_EventCopy_CreationCode] ON [dbo].[TAN_EventCopy] ([CreationCodeId]) WITH (STATISTICS_NORECOMPUTE=ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TAN_EventCopy_Customer_Archived] ON [dbo].[TAN_EventCopy] ([CustomerIntId]) INCLUDE ([EventId], [VehicleIntId], [DriverIntId], [Long], [Lat], [Heading], [Speed], [EventDateTime]) WITH (STATISTICS_NORECOMPUTE=ON) ON [PRIMARY]
GO
