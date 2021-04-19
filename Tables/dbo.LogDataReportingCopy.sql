CREATE TABLE [dbo].[LogDataReportingCopy]
(
[LogDataId] [bigint] NOT NULL,
[VehicleIntId] [int] NULL,
[IVHId] [int] NULL,
[LogNumber] [int] NOT NULL,
[LogDateTime] [datetime] NOT NULL,
[RunTime] [int] NOT NULL,
[DecelTime] [int] NOT NULL,
[StatTime] [int] NOT NULL,
[EcoTime] [int] NOT NULL,
[TotalDistance] [float] NULL,
[MovingFuel] [float] NOT NULL,
[StatFuel] [float] NOT NULL,
[LastOperation] [smalldatetime] NULL,
[Archived] [bit] NULL
) ON [PRIMARY]
GO
