CREATE TABLE [dbo].[VT_CAM_VideoStatus]
(
[VideoStatusId] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_VT_CAM_VideoStatus_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_VT_CAM_VideoStatus_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VT_CAM_VideoStatus] ADD CONSTRAINT [PK_VT_CAM_VideoStatus] PRIMARY KEY CLUSTERED  ([VideoStatusId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
