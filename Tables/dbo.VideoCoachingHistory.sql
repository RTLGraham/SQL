CREATE TABLE [dbo].[VideoCoachingHistory]
(
[VideoCoachingId] [bigint] NOT NULL IDENTITY(1, 1),
[IncidentId] [bigint] NOT NULL,
[CoachingStatusId] [smallint] NULL,
[StatusUserId] [uniqueidentifier] NOT NULL,
[StatusDateTime] [datetime] NOT NULL,
[Comments] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_VideoCoachingHistory_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VideoCoachingHistory_Status] ON [dbo].[VideoCoachingHistory] ([CoachingStatusId], [LastOperation]) INCLUDE ([IncidentId], [StatusUserId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VideoCoachingHistory_Incident] ON [dbo].[VideoCoachingHistory] ([IncidentId], [CoachingStatusId]) INCLUDE ([StatusDateTime]) ON [PRIMARY]
GO
