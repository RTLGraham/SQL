CREATE TABLE [dbo].[DriverLatestEvent]
(
[DriverId] [uniqueidentifier] NOT NULL,
[EventId] [bigint] NULL,
[EventDateTime] [datetime] NULL,
[VehicleId] [uniqueidentifier] NULL,
[CreationCodeId] [smallint] NULL,
[Long] [float] NULL,
[Lat] [float] NULL,
[Heading] [smallint] NULL,
[Speed] [smallint] NULL,
[OdoGPS] [int] NULL,
[OdoRoadSpeed] [int] NULL,
[OdoDashboard] [int] NULL,
[VehicleMode] [int] NULL,
[AnalogIoAlertTypeId] [int] NULL,
[DigitalIO] [tinyint] NULL,
[AnalogData0] [smallint] NULL,
[AnalogData1] [smallint] NULL,
[AnalogData2] [smallint] NULL,
[AnalogData3] [smallint] NULL,
[AnalogData4] [smallint] NULL,
[AnalogData5] [smallint] NULL
) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_DriverLatestEvent_DriverId] ON [dbo].[DriverLatestEvent] ([DriverId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DriverLatestEvent] WITH NOCHECK ADD CONSTRAINT [FK_DriverLatestEvent_DriverId] FOREIGN KEY ([DriverId]) REFERENCES [dbo].[Driver] ([DriverId])
GO
ALTER TABLE [dbo].[DriverLatestEvent] WITH NOCHECK ADD CONSTRAINT [FK_DriverLatestEvent_VehicleId] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
