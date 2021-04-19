CREATE TABLE [dbo].[VehicleReportConfiguration]
(
[VehicleReportConfigurationId] [int] NOT NULL IDENTITY(1, 1),
[VehicleId] [uniqueidentifier] NULL,
[ReportConfigurationId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleReportConfiguration] ADD CONSTRAINT [PK_VehicleReportConfiguration] PRIMARY KEY CLUSTERED  ([VehicleReportConfigurationId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleReportConfiguration] ADD CONSTRAINT [UQ__VehicleR__476B5493EAC06D7E] UNIQUE NONCLUSTERED  ([VehicleId]) ON [PRIMARY]
GO
