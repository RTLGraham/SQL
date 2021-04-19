CREATE TABLE [dbo].[ReportScheduleActivity]
(
[ReportScheduleActivityId] [int] NOT NULL IDENTITY(1, 1),
[ReportScheduleId] [int] NOT NULL,
[CreatedDateTime] [datetime] NOT NULL,
[Status] [int] NOT NULL,
[ScheduleDateTime] [datetime] NOT NULL,
[StartDateTime] [datetime] NULL,
[CompletedDateTime] [datetime] NULL,
[Recipients] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportScheduleActivity] ADD CONSTRAINT [PK_ReportScheduleActivity] PRIMARY KEY CLUSTERED  ([ReportScheduleActivityId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportScheduleActivity_Status] ON [dbo].[ReportScheduleActivity] ([Status]) INCLUDE ([ReportScheduleId], [ScheduleDateTime]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportScheduleActivity] ADD CONSTRAINT [FK_ReportScheduleActivity_Schedule] FOREIGN KEY ([ReportScheduleId]) REFERENCES [dbo].[ReportSchedule] ([ReportScheduleId])
GO
