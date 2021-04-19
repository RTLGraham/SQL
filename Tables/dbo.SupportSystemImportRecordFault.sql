CREATE TABLE [dbo].[SupportSystemImportRecordFault]
(
[SupportSystemImportRecordFaultId] [int] NOT NULL IDENTITY(1, 1),
[SupportSystemImportId] [int] NOT NULL,
[RecordDate] [datetime] NOT NULL,
[JobId] [int] NOT NULL,
[ParentJobId] [int] NULL,
[ShortDescription] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ClientName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ContactName] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Consultant] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobCreated] [datetime] NOT NULL,
[JobType] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobLastModified] [datetime] NULL,
[JobStatus] [int] NOT NULL,
[MinutesSpent] [int] NULL,
[SecondaryStatus] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EstimatedCompletion] [datetime] NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_SupportSystemImportRecordFault_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_SupportSystemImportRecordFault_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupportSystemImportRecordFault] ADD CONSTRAINT [PK_SupportSystemImportRecordFault] PRIMARY KEY CLUSTERED  ([SupportSystemImportRecordFaultId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupportSystemImportRecordFault] ADD CONSTRAINT [FK_SupportSystemImportRecordFault_SupportSystemImport] FOREIGN KEY ([SupportSystemImportId]) REFERENCES [dbo].[SupportSystemImport] ([SupportSystemImportId])
GO
