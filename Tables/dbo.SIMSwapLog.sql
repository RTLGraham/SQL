CREATE TABLE [dbo].[SIMSwapLog]
(
[VehicleId] [uniqueidentifier] NULL,
[VehicleIntId] [int] NULL,
[Registration] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Command] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CommandIssued] [datetime] NULL,
[CommandAcknowledged] [datetime] NULL,
[DownloadStarted] [datetime] NULL,
[DownloadedCompleted] [datetime] NULL,
[DownloadedFailed] [datetime] NULL,
[APNIssued] [datetime] NULL,
[APNChanged] [datetime] NULL,
[Firmware] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [datetime] NULL,
[ActiveMinutesAfterAPN] [int] NULL,
[ExecutionTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
