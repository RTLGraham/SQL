CREATE TABLE [dbo].[TripsAndStops_RouteAnalysis]
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
[BrokenData] [bit] NULL,
[GeofenceId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripsAndStops_RouteAnalysis] ADD CONSTRAINT [PK_TripsAndStops_RouteAnalysis] PRIMARY KEY CLUSTERED  ([TripsAndStopsID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TripsAndStops_RouteAnalysis_CustomerStateDateTime] ON [dbo].[TripsAndStops_RouteAnalysis] ([CustomerIntID], [VehicleState], [Timestamp], [Latitude], [Longitude]) INCLUDE ([TripsAndStopsID], [VehicleIntID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
