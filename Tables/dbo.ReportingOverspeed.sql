CREATE TABLE [dbo].[ReportingOverspeed]
(
[ReportingOverspeedId] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[OverspeedDistance] [float] NULL,
[Date] [smalldatetime] NOT NULL,
[Rows] [int] NULL,
[RouteId] [int] NULL,
[OverSpeedHighDistance] [float] NULL,
[Incidents] [int] NULL,
[Observations] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportingOverspeed] ADD CONSTRAINT [PK_ReportingOverspeed] PRIMARY KEY CLUSTERED  ([ReportingOverspeedId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingOverspeed] ON [dbo].[ReportingOverspeed] ([Date], [VehicleIntId], [DriverIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingOverspeed_DriverDate] ON [dbo].[ReportingOverspeed] ([DriverIntId], [Date]) INCLUDE ([VehicleIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingOverspeed_VehicleDate] ON [dbo].[ReportingOverspeed] ([VehicleIntId], [Date]) INCLUDE ([DriverIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingOverspeed_VehicleDriverDate] ON [dbo].[ReportingOverspeed] ([VehicleIntId], [DriverIntId], [Date]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportingOverspeed] ADD CONSTRAINT [FK_ReportingOverspeed_Driver] FOREIGN KEY ([DriverIntId]) REFERENCES [dbo].[Driver] ([DriverIntId])
GO
ALTER TABLE [dbo].[ReportingOverspeed] ADD CONSTRAINT [FK_ReportingOverspeed_Route] FOREIGN KEY ([RouteId]) REFERENCES [dbo].[Route] ([RouteID])
GO
ALTER TABLE [dbo].[ReportingOverspeed] ADD CONSTRAINT [FK_ReportingOverspeed_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
