CREATE TABLE [dbo].[ReportSchedule]
(
[ReportScheduleId] [int] NOT NULL IDENTITY(1, 1),
[Description] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UserId] [uniqueidentifier] NOT NULL,
[ReportId] [uniqueidentifier] NOT NULL,
[ReportPeriodTypeId] [int] NOT NULL,
[DayList] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateList] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SchTime] [datetime] NOT NULL,
[ExportFormat] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EmailSubject] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecipientsTo] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecipientsCC] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecipientsBCC] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExecutionCount] [int] NOT NULL CONSTRAINT [DF__ReportSch__Execu__781667FA] DEFAULT ((0)),
[Archived] [bit] NULL,
[ReplyTo] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Disabled] [bit] NOT NULL CONSTRAINT [DF__ReportSch__Disab__790A8C33] DEFAULT ((0)),
[ReportRDLId] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ============================================================================================
-- Author:		Graham Pattison
-- Create date: 09/03/2011
-- Description:	Any EventsData rows with CreationCodeId matching TAN_TriggerType.CreationCodeId
--				will be inserted into TAN_TriggerEvent to be analysed by the TAN process.
-- ============================================================================================
CREATE TRIGGER [dbo].[trig_Insert_ReportSchedule] 
   ON  [dbo].[ReportSchedule]
   AFTER INSERT
AS 
BEGIN
		
INSERT INTO dbo.ReportScheduleActivity
        ( ReportScheduleId,
          CreatedDateTime,
          Status,
          ScheduleDateTime,
          StartDateTime,
          CompletedDateTime,
          Recipients
        )
SELECT  i.ReportScheduleId,
		GETUTCDATE(),
		0,
		dbo.GetNextScheduleDateTime(i.DayList, i.DateList, i.SchTime, i.UserId),
		NULL,
		NULL,
		NULL
FROM INSERTED i
WHERE i.Archived != 1
  AND i.[Disabled] = 0

END


















GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ============================================================================================
-- Author:		Graham Pattison
-- Create date: 11/10/2013
-- Description:	Any rows updated in ReportSchedule will cause any current reports scheduled in
--				ReportScheduleActivity to be deleted and a new row inserted. Reports scheduled
--				for immediate execution (Daylist = '0') will NOT be rescheduled
-- ============================================================================================
CREATE TRIGGER [dbo].[trig_Update_ReportSchedule] 
   ON  [dbo].[ReportSchedule]
   AFTER UPDATE
AS 
BEGIN

DELETE
FROM dbo.ReportScheduleActivity
FROM dbo.ReportScheduleActivity rsa
INNER JOIN DELETED d ON rsa.ReportScheduleId = d.ReportScheduleId
WHERE rsa.Status = 0
		
INSERT INTO dbo.ReportScheduleActivity
        ( ReportScheduleId,
          CreatedDateTime,
          Status,
          ScheduleDateTime,
          StartDateTime,
          CompletedDateTime,
          Recipients
        )
SELECT  i.ReportScheduleId,
		GETUTCDATE(),
		0,
		dbo.GetNextScheduleDateTime(i.DayList, i.DateList, i.SchTime, i.UserId),
		NULL,
		NULL,
		NULL
FROM INSERTED i
WHERE i.Archived != 1
  AND i.[Disabled] = 0
  AND DayList != '0' -- Don't reschedule an immediate report

END


















GO
ALTER TABLE [dbo].[ReportSchedule] ADD CONSTRAINT [PK_ReportSchedule] PRIMARY KEY CLUSTERED  ([ReportScheduleId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportSchedule] ADD CONSTRAINT [FK_ReportSchedule_PeriodType] FOREIGN KEY ([ReportPeriodTypeId]) REFERENCES [dbo].[ReportPeriodType] ([ReportPeriodTypeId])
GO
ALTER TABLE [dbo].[ReportSchedule] ADD CONSTRAINT [FK_ReportSchedule_Report] FOREIGN KEY ([ReportId]) REFERENCES [dbo].[Report] ([ReportId])
GO
ALTER TABLE [dbo].[ReportSchedule] ADD CONSTRAINT [FK_ReportSchedule_ReportRDL] FOREIGN KEY ([ReportRDLId]) REFERENCES [dbo].[ReportRDL] ([ReportRDLId])
GO
