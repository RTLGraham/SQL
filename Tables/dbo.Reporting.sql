CREATE TABLE [dbo].[Reporting]
(
[ReportingId] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[InSweetSpotDistance] [float] NULL,
[FueledOverRPMDistance] [float] NULL,
[TopGearDistance] [float] NULL,
[CruiseControlDistance] [float] NULL,
[CoastInGearDistance] [float] NULL,
[IdleTime] [int] NULL,
[TotalTime] [int] NULL,
[EngineBrakeDistance] [float] NULL,
[ServiceBrakeDistance] [float] NULL,
[EngineBrakeOverRPMDistance] [float] NULL,
[ROPCount] [int] NULL,
[OverSpeedDistance] [float] NULL,
[CoastOutOfGearDistance] [float] NULL,
[PanicStopCount] [int] NULL,
[TotalFuel] [float] NULL,
[TimeNoID] [float] NULL,
[TimeID] [float] NULL,
[DrivingDistance] [float] NULL,
[PTOMovingDistance] [float] NULL,
[Date] [smalldatetime] NOT NULL,
[Rows] [int] NULL,
[DrivingFuel] [float] NULL,
[PTOMovingTime] [int] NULL,
[PTOMovingFuel] [float] NULL,
[PTONonMovingTime] [int] NULL,
[PTONonMovingFuel] [float] NULL,
[DigitalInput2Count] [int] NULL,
[RouteID] [int] NULL,
[PassengerComfort] [float] NULL,
[ORCount] [int] NULL,
[CruiseInTopGearsDistance] [float] NULL,
[GearDownDistance] [float] NULL,
[ROP2Count] [int] NULL,
[CruiseSpeedingDistance] [float] NULL,
[OverSpeedThresholdDistance] [float] NULL,
[TopGearSpeedingDistance] [float] NULL,
[FuelWastage] [float] NULL,
[EarliestOdoGPS] [bigint] NULL,
[LatestOdoGPS] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Reporting] ADD CONSTRAINT [PK_Reporting] PRIMARY KEY CLUSTERED  ([ReportingId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Reporting] ON [dbo].[Reporting] ([Date], [VehicleIntId], [DriverIntId], [RouteID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Reporting_DriverDate] ON [dbo].[Reporting] ([DriverIntId], [Date]) INCLUDE ([VehicleIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Reporting_VehicleDate] ON [dbo].[Reporting] ([VehicleIntId], [Date]) INCLUDE ([TimeNoID], [TimeID], [DriverIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Reporting_VehicleDriverDate] ON [dbo].[Reporting] ([VehicleIntId], [DriverIntId], [Date]) INCLUDE ([TimeID], [TimeNoID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Reporting] ADD CONSTRAINT [FK_Reporting_Driver] FOREIGN KEY ([DriverIntId]) REFERENCES [dbo].[Driver] ([DriverIntId])
GO
ALTER TABLE [dbo].[Reporting] ADD CONSTRAINT [FK_Reporting_Route] FOREIGN KEY ([RouteID]) REFERENCES [dbo].[Route] ([RouteID])
GO
ALTER TABLE [dbo].[Reporting] ADD CONSTRAINT [FK_Reporting_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
