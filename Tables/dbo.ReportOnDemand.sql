CREATE TABLE [dbo].[ReportOnDemand]
(
[ReportOnDemandId] [int] NOT NULL IDENTITY(1, 1),
[CustomerId] [uniqueidentifier] NULL,
[CustomerReferenceId] [int] NULL,
[RDL] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Exportformat] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Emailto] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Emailcc] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Emailbcc] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Emailsubject] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Paramstring] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [int] NULL,
[StartDateTime] [datetime] NULL,
[CompletedDateTime] [datetime] NULL,
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[Archived] [bit] NULL CONSTRAINT [DF__ReportOnD__Archi__7539FB4F] DEFAULT ((0)),
[UserId] [uniqueidentifier] NULL,
[ReportId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportOnDemand] ADD CONSTRAINT [PK_ReportOnDemand] PRIMARY KEY CLUSTERED  ([ReportOnDemandId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ReportOnDemand_Status] ON [dbo].[ReportOnDemand] ([Status]) INCLUDE ([ReportOnDemandId], [RDL], [Exportformat], [Description], [Emailto], [Emailcc], [Emailbcc], [Emailsubject], [Paramstring]) ON [PRIMARY]
GO
