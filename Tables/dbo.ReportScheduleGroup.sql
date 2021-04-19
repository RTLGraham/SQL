CREATE TABLE [dbo].[ReportScheduleGroup]
(
[ReportScheduleGroupId] [int] NOT NULL IDENTITY(1, 1),
[ReportScheduleId] [int] NOT NULL,
[GroupId] [uniqueidentifier] NOT NULL,
[GroupTypeId] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportScheduleGroup] ADD CONSTRAINT [PK_ReportScheduleGroup] PRIMARY KEY CLUSTERED  ([ReportScheduleGroupId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportScheduleGroup] ADD CONSTRAINT [FK_ReportScheduleGroup_Schedule] FOREIGN KEY ([ReportScheduleId]) REFERENCES [dbo].[ReportSchedule] ([ReportScheduleId])
GO
