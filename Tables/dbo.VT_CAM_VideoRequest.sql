CREATE TABLE [dbo].[VT_CAM_VideoRequest]
(
[VideoRequestId] [bigint] NOT NULL IDENTITY(1, 1),
[RequestId] [int] NULL,
[StartTime] [datetime] NOT NULL,
[CameraIntId] [int] NOT NULL,
[VideoStatusId] [int] NOT NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_VT_CAM_VideoRequest_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_VT_CAM_VideoRequest_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VT_CAM_VideoRequest] ADD CONSTRAINT [PK_VT_CAM_VideoRequest] PRIMARY KEY CLUSTERED  ([VideoRequestId]) WITH (IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VT_CAM_VideoRequest] ADD CONSTRAINT [FK_VT_CAM_VideoRequest_Status] FOREIGN KEY ([VideoStatusId]) REFERENCES [dbo].[VT_CAM_VideoStatus] ([VideoStatusId])
GO
