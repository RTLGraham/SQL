CREATE TABLE [dbo].[VideoDownloadRequest]
(
[VideoDownloadRequestID] [bigint] NOT NULL IDENTITY(1, 1),
[IncidentId] [bigint] NOT NULL,
[ApiEventId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiMetadataId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VideoId] [bigint] NOT NULL,
[ApiVideoId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ApiStartTime] [datetime] NULL,
[ApiEndTime] [datetime] NULL,
[ApiUrl] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ApiUser] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ApiPassword] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RequestDate] [datetime] NOT NULL,
[ProcessInd] [bit] NULL,
[VideoDispatcher] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VideoDownloadRequest] ADD CONSTRAINT [PK_VideoDownloadRequest] PRIMARY KEY CLUSTERED  ([VideoDownloadRequestID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
