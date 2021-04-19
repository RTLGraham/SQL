CREATE TABLE [dbo].[ReportingNCE]
(
[ReportingNCEId] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NOT NULL,
[Date] [smalldatetime] NOT NULL,
[OverLimitDuration] [int] NULL,
[TimedDateTime] [datetime] NULL,
[AnalogData0Timed] [int] NULL,
[AnalogData1Timed] [int] NULL,
[AnalogData2Timed] [int] NULL,
[AnalogData3Timed] [int] NULL,
[AnalogData0AvgInside] [int] NULL,
[AnalogData1AvgInside] [int] NULL,
[AnalogData2AvgInside] [int] NULL,
[AnalogData3AvgInside] [int] NULL,
[AnalogData0AvgOutside] [int] NULL,
[AnalogData1AvgOutside] [int] NULL,
[AnalogData2AvgOutside] [int] NULL,
[AnalogData3AvgOutside] [int] NULL,
[OutsideDuration] [int] NULL,
[OverLimit2Duration] [int] NULL,
[OverLimit3Duration] [int] NULL,
[DriverIntId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportingNCE] ADD CONSTRAINT [PK_ReportingNCE] PRIMARY KEY CLUSTERED  ([ReportingNCEId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingNCE_DriverDate] ON [dbo].[ReportingNCE] ([DriverIntId], [Date]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingNCE_VehicleDate] ON [dbo].[ReportingNCE] ([VehicleIntId], [Date]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingNCE_VehicleDriverDate] ON [dbo].[ReportingNCE] ([VehicleIntId], [DriverIntId], [Date]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportingNCE] ADD CONSTRAINT [FK_ReportingNCE_Driver] FOREIGN KEY ([DriverIntId]) REFERENCES [dbo].[Driver] ([DriverIntId])
GO
ALTER TABLE [dbo].[ReportingNCE] ADD CONSTRAINT [FK_ReportingNCE_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
