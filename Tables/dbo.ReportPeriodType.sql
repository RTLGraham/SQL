CREATE TABLE [dbo].[ReportPeriodType]
(
[ReportPeriodTypeId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplaySeq] [int] NULL,
[Archived] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportPeriodType] ADD CONSTRAINT [PK_ReportPeriodType] PRIMARY KEY CLUSTERED  ([ReportPeriodTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportPeriodType] ADD CONSTRAINT [UQ_ReportPeriodType_Name] UNIQUE NONCLUSTERED  ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
