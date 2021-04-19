CREATE TABLE [dbo].[VehicleLatestEvent]
(
[VehicleId] [uniqueidentifier] NOT NULL,
[EventId] [bigint] NULL,
[EventDateTime] [datetime] NULL,
[DriverId] [uniqueidentifier] NULL,
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
[AnalogData5] [smallint] NULL,
[PaxCount] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VehicleLatestEvent_DriverId] ON [dbo].[VehicleLatestEvent] ([DriverId]) ON [PRIMARY]
GO
CREATE UNIQUE CLUSTERED INDEX [IX_VehicleLatestEvent_VehicleId] ON [dbo].[VehicleLatestEvent] ([VehicleId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleLatestEvent] WITH NOCHECK ADD CONSTRAINT [FK_VehicleLatestEvent_DriverId] FOREIGN KEY ([DriverId]) REFERENCES [dbo].[Driver] ([DriverId])
GO
ALTER TABLE [dbo].[VehicleLatestEvent] WITH NOCHECK ADD CONSTRAINT [FK_VehicleLatestEvent_VehicleId] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
