CREATE TABLE [dbo].[TripAnalysisLeg]
(
[TripAnalysisLegId] [bigint] NOT NULL IDENTITY(1, 1),
[TripAnalysisRequestId] [int] NULL,
[StartId] [bigint] NULL,
[StartLocation] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDescription] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SiteTime] [int] NULL,
[EndId] [bigint] NULL,
[EndLocation] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EndDescription] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TripStart] [datetime] NULL,
[TripEnd] [datetime] NULL,
[Registration] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TripDistance] [int] NULL,
[TripTimeMins] [int] NULL,
[BreakMins] [int] NULL
) ON [PRIMARY]
GO
