CREATE TABLE [dbo].[HeartbeatTemp]
(
[HeartbeatId] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NULL,
[IVHIntId] [int] NULL,
[HeartbeatDateTime] [datetime] NOT NULL,
[Econospeed] [bit] NOT NULL,
[SDCard] [bit] NOT NULL,
[Firmware] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_Heartbeat_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_Heartbeat_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
