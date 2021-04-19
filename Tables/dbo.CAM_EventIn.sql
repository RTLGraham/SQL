CREATE TABLE [dbo].[CAM_EventIn]
(
[EventInId] [bigint] NOT NULL IDENTITY(1, 1),
[ProjectId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VehicleId] [uniqueidentifier] NULL,
[EventDateTime] [datetime] NULL,
[ApiEventId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventType] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CameraId] [uniqueidentifier] NULL,
[Lat] [float] NULL,
[Long] [float] NULL,
[Speed] [smallint] NULL,
[Heading] [smallint] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CAM_EventIn_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_CAM_EventIn_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_EventIn] ADD CONSTRAINT [PK_CAM_EventIn] PRIMARY KEY CLUSTERED  ([EventInId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAMEventIn_Project] ON [dbo].[CAM_EventIn] ([ProjectId], [Archived]) ON [PRIMARY]
GO
