CREATE TABLE [dbo].[Reporting_NonCan]
(
[ReportingId] [bigint] NOT NULL,
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
[ORCount] [int] NULL
) ON [PRIMARY]
GO
