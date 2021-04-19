CREATE TABLE [dbo].[ReportingLogData]
(
[ReportingLogDataId] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NOT NULL,
[Date] [smalldatetime] NOT NULL,
[StartRunTime] [int] NOT NULL,
[StartDecelTime] [int] NOT NULL,
[StartStatTime] [int] NOT NULL,
[StartEcoTime] [int] NOT NULL,
[StartDistance] [float] NOT NULL,
[StartMovingFuel] [float] NOT NULL,
[StartStatFuel] [float] NOT NULL,
[EndRunTime] [int] NULL,
[EndDecelTime] [int] NULL,
[EndStatTime] [int] NULL,
[EndEcoTime] [int] NULL,
[EndDistance] [float] NULL,
[EndMovingFuel] [float] NULL,
[EndStatFuel] [float] NULL,
[LastOperation] [smalldatetime] NULL,
[Archived] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportingLogData] ADD CONSTRAINT [PK_ReportingLogData] PRIMARY KEY CLUSTERED  ([ReportingLogDataId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportingLogData] ADD CONSTRAINT [FK_ReportingLogData_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
