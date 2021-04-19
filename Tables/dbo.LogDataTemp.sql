CREATE TABLE [dbo].[LogDataTemp]
(
[LogDataId] [bigint] NOT NULL IDENTITY(1, 1),
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
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_LogData_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_LogData_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
