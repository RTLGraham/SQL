CREATE TABLE [dbo].[JCM_Job]
(
[JobId] [int] NOT NULL IDENTITY(1, 1),
[ExternalJobId] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobDateTime] [datetime] NOT NULL,
[StatusId] [int] NOT NULL,
[CurrentStepNum] [tinyint] NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_Job_Arc] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_Job_LastOp] DEFAULT (getdate()),
[CurrentStepCompletedDateTime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JCM_Job] ADD CONSTRAINT [PK_JCM_Job] PRIMARY KEY CLUSTERED  ([JobId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JCM_Job] ADD CONSTRAINT [FK_JCM_Job_Status] FOREIGN KEY ([StatusId]) REFERENCES [dbo].[JCM_Status] ([StatusId])
GO
