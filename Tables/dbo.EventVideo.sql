CREATE TABLE [dbo].[EventVideo]
(
[EventVideoId] [bigint] NOT NULL,
[EventId] [bigint] NULL,
[EventDateTime] [datetime] NULL,
[CreationCodeId] [smallint] NULL,
[CustomerIntId] [int] NOT NULL CONSTRAINT [DF_EventVideo_CustomerIntId] DEFAULT ((0)),
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[CoachingStatusId] [int] NULL,
[ApiEventId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiVideoId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiMetadataId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiFileName] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiStartTime] [datetime] NULL,
[ApiEndTime] [datetime] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_EventVideo_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_EventVideo_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EventVideo] ADD CONSTRAINT [PK_EventVideo] PRIMARY KEY CLUSTERED  ([EventVideoId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_EventVideo_ApiEventId] ON [dbo].[EventVideo] ([ApiEventId]) ON [PRIMARY]
GO
