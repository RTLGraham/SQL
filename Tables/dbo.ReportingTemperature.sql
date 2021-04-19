CREATE TABLE [dbo].[ReportingTemperature]
(
[ReportingTemperatureId] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[AvgAnalogData0] [smallint] NULL,
[AvgAnalogData1] [smallint] NULL,
[AvgAnalogData2] [smallint] NULL,
[AvgAnalogData3] [smallint] NULL,
[AvgAnalogData4] [smallint] NULL,
[AvgAnalogData5] [smallint] NULL,
[Date] [smalldatetime] NOT NULL,
[Rows] [int] NULL,
[RouteId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportingTemperature] ADD CONSTRAINT [PK_ReportingTemperature] PRIMARY KEY CLUSTERED  ([ReportingTemperatureId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingTemperature] ON [dbo].[ReportingTemperature] ([Date], [VehicleIntId], [DriverIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingTemperature_DriverDate] ON [dbo].[ReportingTemperature] ([DriverIntId], [Date]) INCLUDE ([VehicleIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingTemperature_VehicleDate] ON [dbo].[ReportingTemperature] ([VehicleIntId], [Date]) INCLUDE ([DriverIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportingTemperature] ADD CONSTRAINT [FK_ReportingTemperature_Driver] FOREIGN KEY ([DriverIntId]) REFERENCES [dbo].[Driver] ([DriverIntId])
GO
ALTER TABLE [dbo].[ReportingTemperature] ADD CONSTRAINT [FK_ReportingTemperature_Route] FOREIGN KEY ([RouteId]) REFERENCES [dbo].[Route] ([RouteID])
GO
ALTER TABLE [dbo].[ReportingTemperature] ADD CONSTRAINT [FK_ReportingTemperature_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
