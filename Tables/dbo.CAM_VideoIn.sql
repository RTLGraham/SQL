CREATE TABLE [dbo].[CAM_VideoIn]
(
[VideoInId] [bigint] NOT NULL IDENTITY(1, 1),
[ApiEventId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiVideoId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiFileName] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiStartTime] [datetime] NULL,
[ApiEndTime] [datetime] NULL,
[CameraNumber] [int] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CAM_VideoIn_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NULL,
[VideoStatus] [int] NOT NULL CONSTRAINT [DF__CAM_Video__Video__2E5C9EBB] DEFAULT ((0)),
[ProjectId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAM_VideoIn_APIEventId] ON [dbo].[CAM_VideoIn] ([ApiEventId], [Archived], [VideoStatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAM_VideoIn_ArchivedProjectId] ON [dbo].[CAM_VideoIn] ([Archived], [ProjectId]) INCLUDE ([ApiEventId], [VideoInId], [ApiVideoId], [ApiFileName], [ApiStartTime], [ApiEndTime], [CameraNumber], [LastOperation], [VideoStatus]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAM_VideoIn_LastOperation] ON [dbo].[CAM_VideoIn] ([LastOperation]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAMVideoIn_Project] ON [dbo].[CAM_VideoIn] ([ProjectId], [Archived]) ON [PRIMARY]
GO
