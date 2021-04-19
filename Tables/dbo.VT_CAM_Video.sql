CREATE TABLE [dbo].[VT_CAM_Video]
(
[VideoId] [bigint] NOT NULL IDENTITY(1, 1),
[IncidentId] [bigint] NOT NULL,
[RequestId] [int] NOT NULL,
[VideoStatusId] [int] NOT NULL,
[RequestTime] [datetime] NULL,
[ApiStartTime] [datetime] NULL,
[ApiEndTime] [datetime] NULL,
[ApiVideoURL] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiAccelerometerURL] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiContentType] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_VT_CAM_Video_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_VT_CAM_Video_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VT_CAM_Video] ADD CONSTRAINT [PK_VT_CAM_Video] PRIMARY KEY CLUSTERED  ([VideoId]) WITH (IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VT_CAM_Video] ADD CONSTRAINT [FK_VT_CAM_Video_Incident] FOREIGN KEY ([IncidentId]) REFERENCES [dbo].[VT_CAM_Incident] ([IncidentId])
GO
ALTER TABLE [dbo].[VT_CAM_Video] ADD CONSTRAINT [FK_VT_CAM_Video_Status] FOREIGN KEY ([VideoStatusId]) REFERENCES [dbo].[VT_CAM_VideoStatus] ([VideoStatusId])
GO
