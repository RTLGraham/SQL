CREATE TABLE [dbo].[ReportScheduleParameter]
(
[ReportScheduleParameterId] [int] NOT NULL IDENTITY(1, 1),
[ReportScheduleId] [int] NOT NULL,
[ReportParameterId] [int] NOT NULL,
[Value] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportScheduleParameter] ADD CONSTRAINT [PK_ReportScheduleParameter] PRIMARY KEY CLUSTERED  ([ReportScheduleParameterId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportScheduleParamter_ReportScheduleId] ON [dbo].[ReportScheduleParameter] ([ReportScheduleId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportScheduleParameter] ADD CONSTRAINT [FK_ReportScheduleParameter_Parameter] FOREIGN KEY ([ReportParameterId]) REFERENCES [dbo].[ReportParameter] ([ReportParameterId])
GO
ALTER TABLE [dbo].[ReportScheduleParameter] ADD CONSTRAINT [FK_ReportScheduleParameter_Schedule] FOREIGN KEY ([ReportScheduleId]) REFERENCES [dbo].[ReportSchedule] ([ReportScheduleId])
GO
