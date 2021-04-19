CREATE TABLE [dbo].[ReportConfiguration]
(
[ReportConfigurationId] [uniqueidentifier] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RDL] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportConfiguration] ADD CONSTRAINT [PK_ReportConfiguration] PRIMARY KEY CLUSTERED  ([ReportConfigurationId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
