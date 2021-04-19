CREATE TABLE [dbo].[TripsAndStops]
(
[TripsAndStopsID] [bigint] NOT NULL,
[EventID] [bigint] NULL,
[CustomerIntID] [int] NULL,
[IVHIntID] [int] NULL,
[VehicleIntID] [int] NULL,
[DriverIntID] [int] NULL,
[VehicleState] [tinyint] NULL,
[Timestamp] [smalldatetime] NULL,
[Latitude] [float] NULL,
[Longitude] [float] NULL,
[PreviousID] [bigint] NULL,
[TripDistance] [int] NULL,
[Duration] [int] NULL,
[Archived] [bit] NULL,
[BrokenData] [bit] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- ================================================================================================
-- Author:		Ben Michael
-- Create date: 05/10/2020
-- Description:	Any Trip End (Key Off) records will generate an entry in TS_SpeedingControl to
--				represent the entire trip. This data will subsequently be used for speed processing
-- ================================================================================================
CREATE TRIGGER [dbo].[trig_TripEndSpeeding] 
   ON  [dbo].[TripsAndStops]
   AFTER INSERT
AS 
BEGIN
		
INSERT INTO dbo.TS_SpeedingControl
(
    DriverIntId,
    VehicleIntId,
    TSStartId,
    TSEndId,
    TSStartDate,
    TSEndDate,
    ProcessInd
)
		SELECT	te.DriverIntID,te.VehicleIntID,ts.TripsAndStopsID,te.TripsAndStopsID,ts.Timestamp,te.Timestamp,0
		FROM	inserted te
		INNER JOIN dbo.TripsAndStops ts ON ts.TripsAndStopsID = te.PreviousID
		WHERE te.VehicleState = 5	
		  -- Exclude trips that are not genuine (additional criteria may be added here)
		  AND te.Timestamp != ts.Timestamp 	
		  AND DATEDIFF(DAY, ts.Timestamp,te.Timestamp) <= 30
		  AND te.Timestamp IS NOT NULL AND ts.Timestamp IS NOT NULL	
		  AND te.VehicleIntID IS NOT NULL	
		  -- Now exclude any particular vehicles as required
		  --AND te.VehicleIntID != 6468


END
GO
ALTER TABLE [dbo].[TripsAndStops] ADD CONSTRAINT [PK_TripsAndStops_1] PRIMARY KEY CLUSTERED  ([TripsAndStopsID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingIndex_1] ON [dbo].[TripsAndStops] ([CustomerIntID], [VehicleIntID], [Timestamp]) INCLUDE ([Latitude], [Longitude]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TripsAndStops_DepotCustomerVehicleStateDateTime, dbo>] ON [dbo].[TripsAndStops] ([CustomerIntID], [VehicleState], [Timestamp]) INCLUDE ([TripsAndStopsID], [VehicleIntID], [Latitude], [Longitude]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FK_TripsAndStops_1] ON [dbo].[TripsAndStops] ([PreviousID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TripsAndStops_VehicleIntId_Timestamp] ON [dbo].[TripsAndStops] ([VehicleIntID], [Timestamp]) ON [PRIMARY]
GO
