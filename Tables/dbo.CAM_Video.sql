CREATE TABLE [dbo].[CAM_Video]
(
[IncidentId] [bigint] NOT NULL,
[ApiEventId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiVideoId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiFileName] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiStartTime] [datetime] NULL,
[ApiEndTime] [datetime] NULL,
[CameraNumber] [int] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CAM_Video_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_CAM_Video_Archived] DEFAULT ((0)),
[VideoStatus] [int] NOT NULL CONSTRAINT [DF__CAM_Video__Video__2D687A82] DEFAULT ((0)),
[VideoId] [bigint] NOT NULL,
[IsVideoStoredLocally] [bit] NOT NULL CONSTRAINT [DF__CAM_Video_IsVideoStoredLocally] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_Video] ADD CONSTRAINT [PK_CAM_Video] PRIMARY KEY CLUSTERED  ([VideoId]) WITH (IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAM_Video_APIEventIdCamNum] ON [dbo].[CAM_Video] ([ApiEventId], [CameraNumber], [Archived], [VideoStatus], [LastOperation]) INCLUDE ([VideoId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAM_Video_APIVideoId] ON [dbo].[CAM_Video] ([ApiVideoId]) INCLUDE ([ApiStartTime]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAM_Video_ArchivedVideoStatus] ON [dbo].[CAM_Video] ([Archived], [VideoStatus]) INCLUDE ([ApiEventId], [VideoId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAM_Video_IncidentCamera] ON [dbo].[CAM_Video] ([IncidentId], [CameraNumber]) ON [PRIMARY]
GO
