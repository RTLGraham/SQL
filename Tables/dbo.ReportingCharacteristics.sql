CREATE TABLE [dbo].[ReportingCharacteristics]
(
[ReportingCharId] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[Date] [smalldatetime] NOT NULL,
[RowIndex] [int] NULL,
[ColIndex] [int] NULL,
[TimeVal] [int] NULL,
[Distance] [float] NULL,
[Fuel] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportingCharacteristics] ADD CONSTRAINT [PK_ReportingCharacteristics] PRIMARY KEY CLUSTERED  ([ReportingCharId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingCharDate] ON [dbo].[ReportingCharacteristics] ([Date], [VehicleIntId], [DriverIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingChar_DriverDate] ON [dbo].[ReportingCharacteristics] ([DriverIntId], [Date]) INCLUDE ([VehicleIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingChar_VehicleDate] ON [dbo].[ReportingCharacteristics] ([VehicleIntId], [Date]) INCLUDE ([DriverIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportingChar_VehicleDriverDate] ON [dbo].[ReportingCharacteristics] ([VehicleIntId], [DriverIntId], [Date]) ON [PRIMARY]
GO
