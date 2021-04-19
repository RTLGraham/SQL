CREATE TABLE [dbo].[ArchiveHistory]
(
[ArchiveHistoryId] [int] NOT NULL IDENTITY(1, 1),
[InitialDateTime] [datetime] NULL,
[FinalDateTime] [datetime] NULL,
[LatestArchiveStartDateTime] [datetime] NULL,
[LatestArchiveEndDateTime] [datetime] NULL,
[BackupFileName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BackupDateTime] [datetime] NULL
) ON [PRIMARY]
GO
