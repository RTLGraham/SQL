CREATE TABLE [dbo].[SnapshotTemp]
(
[SnapshotId] [bigint] NOT NULL IDENTITY(1, 1),
[EngineRPM] [int] NULL,
[RoadSpeed] [float] NULL,
[EngineLoad] [float] NULL,
[Throttle] [float] NULL,
[FuelRate] [float] NULL,
[Status] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalServiceBrakeActuations] [int] NULL,
[TotalFuel] [float] NULL,
[TotalDistance] [float] NULL,
[ServiceBrakeStatus] [tinyint] NULL,
[EngineBrakeStatus] [tinyint] NULL,
[ClutchStatus] [tinyint] NULL,
[PTOStatus] [tinyint] NULL,
[CruiseStatus] [tinyint] NULL,
[RSGStatus] [tinyint] NULL,
[VehicleMode] [smallint] NULL,
[GearStatus] [smallint] NULL,
[CoastingInGearStatus] [smallint] NULL,
[SweetSpotStatus] [smallint] NULL,
[OverSpeedStatus] [smallint] NULL,
[OverRPMStatus] [smallint] NULL,
[DataLinkStatus] [smallint] NULL,
[KeySwitchStatus] [tinyint] NULL,
[GearRatio] [float] NULL,
[TopGearRatio] [float] NULL,
[GearDownRatio] [float] NULL,
[TimeSincePowerOn] [int] NULL,
[SnapshotRecordStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EngineTemp] [smallint] NULL,
[TotalEngineHours] [float] NULL,
[TotalVehicleDistance] [float] NULL,
[TotalGPSDistance] [float] NULL,
[TotalVehicleFuel] [float] NULL,
[InputsStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Reserved] [int] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_SnapshotTemp_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NULL,
[CustomerIntId] [int] NULL,
[EventDateTime] [datetime] NULL,
[CreationCodeId] [smallint] NULL,
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[EventId] [bigint] NULL
) ON [PRIMARY]
GO
