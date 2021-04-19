CREATE TABLE [dbo].[Snapshot]
(
[SnapshotId] [bigint] NOT NULL,
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
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_Snapshot_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_Snapshot_Archived] DEFAULT ((0)),
[CustomerIntId] [int] NULL,
[EventDateTime] [datetime] NULL,
[CreationCodeId] [smallint] NULL,
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[EventId] [bigint] NULL
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
CREATE TRIGGER [dbo].[trig_SnapshotROPCopy] 
   ON  [dbo].[Snapshot] 
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Copy Snapshots that are likely to be ROPS.
	-- Must also check creationcode=7 but we need a join for this so we do it later.
	-- NB we have 3 extra cols on the end of the table that we populate with data from the events table later
	INSERT INTO SnapshotROPCopy
		SELECT	*
		FROM	inserted 
		WHERE	Reserved > 50

END




GO
ALTER TABLE [dbo].[Snapshot] ADD CONSTRAINT [PK_Snapshot] PRIMARY KEY CLUSTERED  ([SnapshotId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Snapshot_Vehicle_DateTime] ON [dbo].[Snapshot] ([VehicleIntId], [EventDateTime]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Snapshot] ADD CONSTRAINT [FK_Snapshot_CreationCode] FOREIGN KEY ([CreationCodeId]) REFERENCES [dbo].[CreationCode] ([CreationCodeId])
GO
ALTER TABLE [dbo].[Snapshot] WITH NOCHECK ADD CONSTRAINT [FK_Snapshot_Status] FOREIGN KEY ([VehicleMode]) REFERENCES [dbo].[Status] ([StatusId])
GO
ALTER TABLE [dbo].[Snapshot] WITH NOCHECK ADD CONSTRAINT [FK_Snapshot_Status1] FOREIGN KEY ([GearStatus]) REFERENCES [dbo].[Status] ([StatusId])
GO
ALTER TABLE [dbo].[Snapshot] WITH NOCHECK ADD CONSTRAINT [FK_Snapshot_Status2] FOREIGN KEY ([CoastingInGearStatus]) REFERENCES [dbo].[Status] ([StatusId])
GO
ALTER TABLE [dbo].[Snapshot] WITH NOCHECK ADD CONSTRAINT [FK_Snapshot_Status3] FOREIGN KEY ([SweetSpotStatus]) REFERENCES [dbo].[Status] ([StatusId])
GO
ALTER TABLE [dbo].[Snapshot] WITH NOCHECK ADD CONSTRAINT [FK_Snapshot_Status4] FOREIGN KEY ([OverSpeedStatus]) REFERENCES [dbo].[Status] ([StatusId])
GO
ALTER TABLE [dbo].[Snapshot] WITH NOCHECK ADD CONSTRAINT [FK_Snapshot_Status5] FOREIGN KEY ([OverRPMStatus]) REFERENCES [dbo].[Status] ([StatusId])
GO
ALTER TABLE [dbo].[Snapshot] WITH NOCHECK ADD CONSTRAINT [FK_Snapshot_Status6] FOREIGN KEY ([DataLinkStatus]) REFERENCES [dbo].[Status] ([StatusId])
GO
ALTER TABLE [dbo].[Snapshot] WITH NOCHECK ADD CONSTRAINT [FK_Snapshot_StatusActivation] FOREIGN KEY ([ServiceBrakeStatus]) REFERENCES [dbo].[StatusActivation] ([StatusActivationId])
GO
ALTER TABLE [dbo].[Snapshot] WITH NOCHECK ADD CONSTRAINT [FK_Snapshot_StatusActivation1] FOREIGN KEY ([EngineBrakeStatus]) REFERENCES [dbo].[StatusActivation] ([StatusActivationId])
GO
ALTER TABLE [dbo].[Snapshot] WITH NOCHECK ADD CONSTRAINT [FK_Snapshot_StatusActivation2] FOREIGN KEY ([ClutchStatus]) REFERENCES [dbo].[StatusActivation] ([StatusActivationId])
GO
ALTER TABLE [dbo].[Snapshot] WITH NOCHECK ADD CONSTRAINT [FK_Snapshot_StatusActivation3] FOREIGN KEY ([PTOStatus]) REFERENCES [dbo].[StatusActivation] ([StatusActivationId])
GO
ALTER TABLE [dbo].[Snapshot] WITH NOCHECK ADD CONSTRAINT [FK_Snapshot_StatusActivation4] FOREIGN KEY ([CruiseStatus]) REFERENCES [dbo].[StatusActivation] ([StatusActivationId])
GO
ALTER TABLE [dbo].[Snapshot] WITH NOCHECK ADD CONSTRAINT [FK_Snapshot_StatusActivation5] FOREIGN KEY ([RSGStatus]) REFERENCES [dbo].[StatusActivation] ([StatusActivationId])
GO
ALTER TABLE [dbo].[Snapshot] WITH NOCHECK ADD CONSTRAINT [FK_Snapshot_StatusActivation6] FOREIGN KEY ([KeySwitchStatus]) REFERENCES [dbo].[StatusActivation] ([StatusActivationId])
GO
