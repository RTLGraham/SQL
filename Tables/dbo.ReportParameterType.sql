CREATE TABLE [dbo].[ReportParameterType]
(
[ReportParameterTypeId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportParameterType] ADD CONSTRAINT [PK_ReportParameterType] PRIMARY KEY CLUSTERED  ([ReportParameterTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportParameterType] ADD CONSTRAINT [UQ_ReportParameterType_Name] UNIQUE NONCLUSTERED  ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
