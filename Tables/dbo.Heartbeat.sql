CREATE TABLE [dbo].[Heartbeat]
(
[HeartbeatId] [bigint] NOT NULL,
[VehicleIntId] [int] NULL,
[IVHIntId] [int] NULL,
[HeartbeatDateTime] [datetime] NOT NULL,
[Econospeed] [bit] NOT NULL,
[SDCard] [bit] NOT NULL,
[Firmware] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastOperation] [smalldatetime] NULL,
[Archived] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Heartbeat] ADD CONSTRAINT [PK_Heartbeat] PRIMARY KEY CLUSTERED  ([HeartbeatId]) WITH (IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Heartbeat_Vehicle] ON [dbo].[Heartbeat] ([VehicleIntId]) ON [PRIMARY]
GO
