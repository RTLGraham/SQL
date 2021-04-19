CREATE TABLE [dbo].[TripAnalysisSummary]
(
[TripAnalysisSummaryId] [int] NOT NULL IDENTITY(1, 1),
[TripAnalysisRequestId] [int] NULL,
[StartId] [bigint] NULL,
[StartLocation] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDescription] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EndId] [bigint] NULL,
[EndLocation] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EndDescription] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinDurationMins] [int] NULL,
[MaxDurationMins] [int] NULL,
[AvgDurationMins] [int] NULL,
[TripCount] [int] NULL,
[MinDistance] [int] NULL,
[MaxDistance] [int] NULL,
[AvgDistance] [int] NULL
) ON [PRIMARY]
GO
