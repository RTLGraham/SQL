CREATE TABLE [dbo].[Accum]
(
[AccumId] [bigint] NOT NULL,
[CustomerIntId] [int] NOT NULL,
[VehicleIntId] [int] NOT NULL,
[DriverIntId] [int] NOT NULL,
[RouteID] [int] NOT NULL,
[CreationCodeId] [smallint] NOT NULL,
[CreationDateTime] [datetime] NOT NULL,
[ClosureCodeId] [smallint] NOT NULL,
[ClosureDateTime] [datetime] NOT NULL,
[ClosureLat] [float] NOT NULL,
[ClosureLong] [float] NOT NULL,
[DrivingTime] [int] NOT NULL,
[DrivingDistance] [float] NOT NULL,
[DrivingFuel] [float] NOT NULL,
[IdleTime] [int] NOT NULL,
[IdleFuel] [float] NOT NULL,
[ShortIdleTime] [int] NOT NULL,
[ShortIdleFuel] [float] NOT NULL,
[PTONonMovingTime] [int] NOT NULL,
[PTONonMovingFuel] [float] NOT NULL,
[PTOMovingTime] [int] NOT NULL,
[PTOMovingDistance] [float] NOT NULL,
[PTOMovingFuel] [float] NOT NULL,
[CruiseControlTime] [int] NOT NULL,
[CruiseControlDistance] [float] NOT NULL,
[CruiseControlFuel] [float] NOT NULL,
[RSGTime] [int] NOT NULL,
[RSGDistance] [float] NOT NULL,
[RSGFuel] [float] NOT NULL,
[TopGearTime] [int] NOT NULL,
[TopGearDistance] [float] NOT NULL,
[TopGearFuel] [float] NOT NULL,
[GearDownTime] [int] NOT NULL,
[GearDownDistance] [float] NOT NULL,
[GearDownFuel] [float] NOT NULL,
[CoastOutOfGearTime] [int] NOT NULL,
[CoastOutOfGearDistance] [float] NOT NULL,
[CoastOutOfGearCount] [smallint] NOT NULL,
[CoastInGearTime] [int] NOT NULL,
[CoastInGearDistance] [float] NOT NULL,
[CoastInGearFuel] [float] NOT NULL,
[BelowSweetSpotTime] [int] NOT NULL,
[BelowSweetSpotDistance] [float] NOT NULL,
[BelowSweetSpotFuel] [float] NOT NULL,
[InSweetSpotTime] [int] NOT NULL,
[InSweetSpotDistance] [float] NOT NULL,
[InSweetSpotFuel] [float] NOT NULL,
[AboveSweetSpotTime] [int] NOT NULL,
[AboveSweetSpotDistance] [float] NOT NULL,
[AboveSweetSpotFuel] [float] NOT NULL,
[OverSpeedTime] [int] NOT NULL,
[OverSpeedDistance] [float] NOT NULL,
[OverSpeedFuel] [float] NOT NULL,
[FueledOverRPMTime] [int] NOT NULL,
[FueledOverRPMDistance] [float] NOT NULL,
[FueledOverRPMFuel] [float] NOT NULL,
[EngineBrakeOverRPMTime] [int] NOT NULL,
[EngineBrakeOverRPMDistance] [float] NOT NULL,
[AverageEngineRPM] [smallint] NULL,
[AverageEngineRPMWhileDriving] [smallint] NULL,
[DataLinkDownTime] [int] NOT NULL,
[ServiceBrakeTime] [int] NOT NULL,
[ServiceBrakeDistance] [float] NOT NULL,
[ServiceBrakeCount] [smallint] NOT NULL,
[EngineBrakeTime] [int] NOT NULL,
[EngineBrakeDistance] [float] NOT NULL,
[EngineBrakeCount] [smallint] NOT NULL,
[MaxRPM] [smallint] NULL,
[MaxRPMTimestamp] [datetime] NOT NULL,
[MaxRPMLat] [float] NOT NULL,
[MaxRPMLong] [float] NOT NULL,
[MaxRoadSpeedTime] [int] NOT NULL,
[MaxRoadSpeedDistance] [float] NOT NULL,
[MaxRoadSpeedFuel] [float] NOT NULL,
[MaxRoadSpeed] [smallint] NOT NULL,
[MaxRoadSpeedTimestamp] [datetime] NOT NULL,
[MaxRoadSpeedLat] [float] NOT NULL,
[MaxRoadSpeedLong] [float] NOT NULL,
[LongestCoastOutofgearTime] [int] NOT NULL,
[LongestCoastOutofgearTimeDistance] [float] NOT NULL,
[LongestCoastOutofgearTimeTimestamp] [datetime] NOT NULL,
[LongestCoastOutofgearTimeLat] [float] NOT NULL,
[LongestCoastOutofgearTimeLong] [float] NOT NULL,
[LongestIdleTime] [int] NOT NULL,
[LongestIdleFuel] [float] NOT NULL,
[LongestIdleTimestamp] [datetime] NOT NULL,
[LongestIdleLat] [float] NOT NULL,
[LongestIdleLong] [float] NOT NULL,
[PanicStopCount] [smallint] NOT NULL,
[EngineTempMidrangeTime] [int] NOT NULL,
[EngineTempHighTime] [int] NOT NULL,
[MaxEngineCoolantTemp] [smallint] NOT NULL,
[AverageEngineLoad] [float] NOT NULL,
[DataValidity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[OverSpeedHighTime] [int] NOT NULL,
[OverSpeedHighDistance] [float] NOT NULL,
[OverSpeedHighFuel] [float] NOT NULL,
[TotalEngineHours] [float] NOT NULL,
[TotalVehicleDistance] [float] NOT NULL,
[TotalVehicleFuel] [float] NOT NULL,
[DigitalInput1Count] [smallint] NOT NULL,
[DigitalInput1ActivationTime] [int] NOT NULL,
[DigitalInput2Count] [smallint] NOT NULL,
[DigitalInput2ActivationTime] [int] NOT NULL,
[CruiseAverageEngineLoad] [float] NOT NULL,
[RSGAverageEngineLoad] [float] NOT NULL,
[TopGearAverageEngineLoad] [float] NOT NULL,
[GearDownAverageEngineLoad] [float] NOT NULL,
[AverageWeight] [int] NOT NULL,
[EngineLoad0Time] [int] NULL,
[EngineLoad0DIstance] [float] NULL,
[EngineLoad0Fuel] [float] NULL,
[EngineLoad100Time] [int] NULL,
[EngineLoad100DIstance] [float] NULL,
[EngineLoad100Fuel] [float] NULL,
[DriveFuelWhole] [int] NULL,
[DriveFuelFrac] [int] NULL,
[ORCount] [int] NULL,
[LastOperation] [smalldatetime] NULL,
[Archived] [bit] NOT NULL,
[CruiseTopGearTime] [int] NULL,
[CruiseTopGearDistance] [float] NULL,
[CruiseTopGearFuel] [float] NULL,
[CruiseGearDownTime] [int] NULL,
[CruiseGearDownDistance] [float] NULL,
[CruiseGearDownFuel] [float] NULL,
[CruiseSpeedingTime] [int] NULL,
[CruiseSpeedingDistance] [float] NULL,
[CruiseSpeedingFuel] [float] NULL,
[StatusFlags] [int] NULL,
[TopGearSpeedingTime] [int] NULL,
[TopGearSpeedingDistance] [float] NULL,
[TopGearSpeedingFuel] [float] NULL,
[OverSpeedThresholdTime] [int] NULL,
[OverSpeedThresholdDistance] [float] NULL,
[OverSpeedThresholdFuel] [float] NULL,
[SeqNumber] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[trig_AccumReportingCopy] 
   ON  [dbo].[Accum] 
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO AccumReportingCopy
		SELECT	*
		FROM	inserted 

END

GO
ALTER TABLE [dbo].[Accum] ADD CONSTRAINT [PK_Accum] PRIMARY KEY CLUSTERED  ([AccumId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Accum_VehicleIntId_CreationDateTime] ON [dbo].[Accum] ([VehicleIntId], [CreationDateTime]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'Creation Code - Closure in Events', 'SCHEMA', N'dbo', 'TABLE', N'Accum', 'COLUMN', N'CreationCodeId'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Creation Timestamp - Closure in Events', 'SCHEMA', N'dbo', 'TABLE', N'Accum', 'COLUMN', N'CreationDateTime'
GO
