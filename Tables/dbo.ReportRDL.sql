CREATE TABLE [dbo].[ReportRDL]
(
[ReportRDLId] [int] NOT NULL IDENTITY(1, 1),
[ReportId] [uniqueidentifier] NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RDL] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [ReportRDL_Archived] DEFAULT ((0)),
[DisplaySeq] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportRDL] ADD CONSTRAINT [PK_ReportRDL] PRIMARY KEY CLUSTERED  ([ReportRDLId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportRDL] ADD CONSTRAINT [FK_ReportRDL_Report] FOREIGN KEY ([ReportId]) REFERENCES [dbo].[Report] ([ReportId])
GO
