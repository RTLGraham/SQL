CREATE TABLE [dbo].[ListenerParseLog]
(
[ListenerParseLogId] [bigint] NOT NULL IDENTITY(1, 1),
[ListenerPort] [int] NULL,
[ListenerName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogDateTime] [datetime] NULL,
[RawCount] [int] NULL,
[CurrentParseSize] [int] NULL,
[CurrentParseIndex] [int] NULL,
[PrevParseDurationSecs] [int] NULL,
[AvgPrevParseDurationMs] [float] NULL,
[AvgPrevParseDurationEventsMs] [float] NULL,
[AvgPrevParseDurationAccumsMs] [float] NULL,
[AvgPrevParseDurationOtherMs] [float] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ListenerParseLog_Port_DateTime] ON [dbo].[ListenerParseLog] ([ListenerPort], [LogDateTime]) ON [PRIMARY]
GO
