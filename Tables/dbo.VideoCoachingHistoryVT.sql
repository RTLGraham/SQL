CREATE TABLE [dbo].[VideoCoachingHistoryVT]
(
[VideoCoachingVTId] [bigint] NOT NULL IDENTITY(1, 1),
[IncidentId] [bigint] NOT NULL,
[CoachingStatusId] [smallint] NULL,
[StatusUserId] [uniqueidentifier] NOT NULL,
[StatusDateTime] [datetime] NOT NULL,
[Comments] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_VideoCoachingHistoryVT_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL
) ON [PRIMARY]
GO
