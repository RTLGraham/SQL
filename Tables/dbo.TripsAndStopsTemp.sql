CREATE TABLE [dbo].[TripsAndStopsTemp]
(
[TripsAndStopsID] [bigint] NOT NULL IDENTITY(1, 1),
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
ALTER TABLE [dbo].[TripsAndStopsTemp] ADD CONSTRAINT [PK_TripsAndStops] PRIMARY KEY CLUSTERED  ([TripsAndStopsID]) WITH (FILLFACTOR=80, STATISTICS_NORECOMPUTE=ON) ON [PRIMARY]
GO
