CREATE TABLE [dbo].[EventListenerTemp]
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
[EventDateTime] [datetime] NULL,
[DigitalIO] [tinyint] NULL,
[CustomerIntId] [int] NULL,
[AnalogData0] [smallint] NULL,
[AnalogData1] [smallint] NULL,
[AnalogData2] [smallint] NULL,
[AnalogData3] [smallint] NULL,
[AnalogData4] [smallint] NULL,
[AnalogData5] [smallint] NULL,
[SeqNumber] [int] NULL,
[SpeedLimit] [tinyint] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_EventListenerTemp_LastOperation] DEFAULT (getdate()),
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