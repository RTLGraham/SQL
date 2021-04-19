CREATE TABLE [dbo].[ReportParameter]
(
[ReportParameterId] [int] NOT NULL IDENTITY(1, 1),
[ReportId] [uniqueidentifier] NOT NULL,
[Seq] [int] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReportParameterTypeId] [int] NOT NULL,
[IsList] [bit] NOT NULL CONSTRAINT [DF__ReportPar__IsLis__762E1F88] DEFAULT ((0)),
[Labels] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Values] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Prompt] [bit] NULL,
[Nullable] [bit] NULL,
[Default] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportParameter] ADD CONSTRAINT [PK_ReportParameter] PRIMARY KEY CLUSTERED  ([ReportParameterId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportParameter_ReportId] ON [dbo].[ReportParameter] ([ReportId], [Archived]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportParameter] ADD CONSTRAINT [FK_ReportParameter_ParameterType] FOREIGN KEY ([ReportParameterTypeId]) REFERENCES [dbo].[ReportParameterType] ([ReportParameterTypeId])
GO
ALTER TABLE [dbo].[ReportParameter] ADD CONSTRAINT [FK_ReportParameter_Report] FOREIGN KEY ([ReportId]) REFERENCES [dbo].[Report] ([ReportId])
GO
