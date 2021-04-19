CREATE TABLE [dbo].[TemperatureHistogram]
(
[HistogramId] [bigint] NOT NULL IDENTITY(1, 1),
[Date] [datetime] NULL,
[VehicleIntId] [int] NULL,
[SensorId] [tinyint] NULL,
[BucketId] [tinyint] NULL,
[InGeofence] [tinyint] NULL,
[Duration] [int] NULL
) ON [PRIMARY]
GO
