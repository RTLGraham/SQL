CREATE TABLE [dbo].[CAM_SoftLock]
(
[ProcessName] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LockTable] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LockTime] [datetime] NULL,
[LockStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
