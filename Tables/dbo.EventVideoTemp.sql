CREATE TABLE [dbo].[EventVideoTemp]
(
[EventVideoId] [bigint] NOT NULL IDENTITY(1, 1),
[EventId] [bigint] NULL,
[EventDateTime] [datetime] NULL,
[CreationCodeId] [smallint] NULL,
[CustomerIntId] [int] NOT NULL CONSTRAINT [DF_EventVideoTemp_CustomerIntId] DEFAULT ((0)),
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[CoachingStatusId] [int] NULL,
[ApiEventId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiVideoId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiMetadataId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiFileName] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiStartTime] [datetime] NULL,
[ApiEndTime] [datetime] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_EventVideoTemp_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NULL
) ON [PRIMARY]
GO
