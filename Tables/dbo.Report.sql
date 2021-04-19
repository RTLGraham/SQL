CREATE TABLE [dbo].[Report]
(
[ReportId] [uniqueidentifier] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WidgetTypeId] [int] NULL,
[RDLPath] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomRDLSuffix] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Report] ADD CONSTRAINT [PK_Report] PRIMARY KEY CLUSTERED  ([ReportId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Report] ADD CONSTRAINT [FK_Report_WidgetType] FOREIGN KEY ([WidgetTypeId]) REFERENCES [dbo].[WidgetType] ([WidgetTypeID])
GO
