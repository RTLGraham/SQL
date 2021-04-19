CREATE TABLE [dbo].[LW_LoneWorker]
(
[LoneWorkerId] [bigint] NOT NULL IDENTITY(1, 1),
[DriverId] [uniqueidentifier] NULL,
[StartTime] [datetime] NULL,
[Duration] [int] NULL,
[StopTime] [datetime] NULL,
[Lat] [float] NULL,
[Lon] [float] NULL,
[PosX] [float] NULL,
[PosY] [float] NULL,
[PosZ] [float] NULL,
[Speed] [float] NULL,
[AlarmTriggeredDateTime] [datetime] NULL,
[PanicStart] [datetime] NULL,
[PanicRelease] [datetime] NULL,
[AddtlData] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LW_LoneWorker] ADD CONSTRAINT [PK_LW_LoneWorker] PRIMARY KEY CLUSTERED  ([LoneWorkerId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
