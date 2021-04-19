CREATE TABLE [dbo].[ReportingTachograph]
(
[ReportingTachographId] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[Rest] [int] NULL,
[Available] [int] NULL,
[Work] [int] NULL,
[Drive] [int] NULL,
[Error] [int] NULL,
[Unavailable] [int] NULL,
[Unknown] [int] NULL,
[Date] [smalldatetime] NULL,
[Rows] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportingTachograph] ADD CONSTRAINT [PK_ReportingTachograph] PRIMARY KEY CLUSTERED  ([ReportingTachographId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportingTachograph] ADD CONSTRAINT [FK_ReportingTachograph_Driver] FOREIGN KEY ([DriverIntId]) REFERENCES [dbo].[Driver] ([DriverIntId])
GO
ALTER TABLE [dbo].[ReportingTachograph] ADD CONSTRAINT [FK_ReportingTachograph_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
