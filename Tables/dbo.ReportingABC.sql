CREATE TABLE [dbo].[ReportingABC]
(
[ReportingABCId] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[Acceleration] [int] NULL,
[Braking] [int] NULL,
[Cornering] [int] NULL,
[Date] [smalldatetime] NOT NULL,
[Rows] [int] NULL,
[RouteId] [int] NULL,
[AccelerationLow] [int] NULL,
[BrakingLow] [int] NULL,
[CorneringLow] [int] NULL,
[AccelerationHigh] [int] NULL,
[BrakingHigh] [int] NULL,
[CorneringHigh] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportingABC] ADD CONSTRAINT [PK_ReportingABC] PRIMARY KEY CLUSTERED  ([ReportingABCId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingABC] ON [dbo].[ReportingABC] ([Date], [VehicleIntId], [DriverIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingABC_DriverDate] ON [dbo].[ReportingABC] ([DriverIntId], [Date]) INCLUDE ([VehicleIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingABC_VehicleDate] ON [dbo].[ReportingABC] ([VehicleIntId], [Date]) INCLUDE ([DriverIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingABC_VehicleDriverDate] ON [dbo].[ReportingABC] ([VehicleIntId], [DriverIntId], [Date]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportingABC] ADD CONSTRAINT [FK_ReportingABC_Driver] FOREIGN KEY ([DriverIntId]) REFERENCES [dbo].[Driver] ([DriverIntId])
GO
ALTER TABLE [dbo].[ReportingABC] ADD CONSTRAINT [FK_ReportingABC_Route] FOREIGN KEY ([RouteId]) REFERENCES [dbo].[Route] ([RouteID])
GO
ALTER TABLE [dbo].[ReportingABC] ADD CONSTRAINT [FK_ReportingABC_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
