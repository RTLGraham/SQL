CREATE TABLE [dbo].[TripAnalysisDetail]
(
[TripAnalysisDetailId] [bigint] NOT NULL IDENTITY(1, 1),
[TripAnalysisRequestId] [int] NULL,
[TripAnalysisSummaryId] [int] NULL,
[StartId] [bigint] NULL,
[StartLocation] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDescription] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EndId] [bigint] NULL,
[EndLocation] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EndDescription] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DepartSite] [datetime] NULL,
[ArriveCustomer] [datetime] NULL,
[Registration] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OutwardDistance] [int] NULL,
[OutwardTimeMins] [int] NULL,
[OutwardBreakMins] [int] NULL,
[UnloadTimeMins] [int] NULL,
[DepartCustomer] [datetime] NULL,
[ArriveSite] [datetime] NULL,
[InwardDistance] [int] NULL,
[InwardTimeMins] [int] NULL,
[InwardBreakMins] [int] NULL
) ON [PRIMARY]
GO
