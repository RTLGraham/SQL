CREATE TABLE [dbo].[ReportingExtra]
(
[ReportingExtraId] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NOT NULL,
[DriverIntId] [int] NOT NULL,
[Date] [smalldatetime] NULL,
[DrivingTime] [int] NULL,
[EngineTime] [int] NULL,
[MovingTime] [int] NULL,
[OverspeedCount] [int] NULL,
[OverSpeedHighCount] [int] NULL,
[StabilityCount] [int] NULL,
[CollisionWarningLow] [int] NULL,
[CollisionWarningMed] [int] NULL,
[CollisionWarningHigh] [int] NULL,
[LaneDepartureDisableCount] [int] NULL,
[LaneDepartureLeftRightCount] [int] NULL,
[SweetSpotTime] [int] NULL,
[OverRPMTime] [int] NULL,
[OverSpeedTime] [int] NULL,
[OverSpeedHighTime] [int] NULL,
[IdleFuel] [float] NULL,
[ParkIdleFuel] [float] NULL,
[PTOTime] [int] NULL,
[PTOFuel] [float] NULL,
[CruiseTime] [int] NULL,
[TopGearTime] [int] NULL,
[Fatigue] [int] NULL,
[Distraction] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportingExtra] ADD CONSTRAINT [PK_ReportingExtra] PRIMARY KEY CLUSTERED  ([ReportingExtraId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportingExtra] ADD CONSTRAINT [FK_ReportingExtra_Driver] FOREIGN KEY ([DriverIntId]) REFERENCES [dbo].[Driver] ([DriverIntId])
GO
ALTER TABLE [dbo].[ReportingExtra] ADD CONSTRAINT [FK_ReportingExtra_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
