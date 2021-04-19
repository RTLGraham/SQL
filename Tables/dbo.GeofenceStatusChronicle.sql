CREATE TABLE [dbo].[GeofenceStatusChronicle]
(
[TruckId] [bigint] NULL,
[GeoEventType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GeoID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lat] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Long] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Time] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EdcEventId] [bigint] NULL,
[CustomerIntId] [int] NULL
) ON [PRIMARY]
GO
