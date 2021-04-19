CREATE TABLE [dbo].[TemperatureHistogramScale]
(
[id] [smallint] NOT NULL IDENTITY(1, 1),
[SensorId] [tinyint] NULL,
[BucketId] [tinyint] NULL,
[TempLow] [float] NULL,
[TempHigh] [float] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TemperatureHistogramScale_Sensor_Temperature] ON [dbo].[TemperatureHistogramScale] ([SensorId], [TempLow], [TempHigh]) INCLUDE ([BucketId]) ON [PRIMARY]
GO
