CREATE TABLE [dbo].[JCM_JobStatusHistory]
(
[JobStatusHistoryId] [int] NOT NULL IDENTITY(1, 1),
[JobId] [int] NOT NULL,
[StatusId] [int] NOT NULL,
[StatusDateTime] [datetime] NOT NULL CONSTRAINT [DF_JobStatusHistory_DateTime] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_JobStatusHistory_Arc] DEFAULT ((0)),
[JobStepId] [int] NULL,
[StepStatus] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JCM_JobStatusHistory] ADD CONSTRAINT [PK_JCM_JobStatusHistory] PRIMARY KEY CLUSTERED  ([JobStatusHistoryId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JCM_JobStatusHistory] ADD CONSTRAINT [FK_JCM_JobStatusHistory_Job] FOREIGN KEY ([JobId]) REFERENCES [dbo].[JCM_Job] ([JobId])
GO
ALTER TABLE [dbo].[JCM_JobStatusHistory] ADD CONSTRAINT [FK_JCM_JobStatusHistory_JobStep] FOREIGN KEY ([JobStepId]) REFERENCES [dbo].[JCM_JobStep] ([JobStepId])
GO
ALTER TABLE [dbo].[JCM_JobStatusHistory] ADD CONSTRAINT [FK_JCM_JobStatusHistory_Status] FOREIGN KEY ([StatusId]) REFERENCES [dbo].[JCM_Status] ([StatusId])
GO
