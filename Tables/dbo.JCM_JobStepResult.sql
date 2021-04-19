CREATE TABLE [dbo].[JCM_JobStepResult]
(
[JobStepResultId] [int] NOT NULL IDENTITY(1, 1),
[JobStepId] [int] NOT NULL,
[NameId] [int] NOT NULL,
[Value] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsReq] [bit] NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_JobResult_Arc] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_JobResult_LastOp] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JCM_JobStepResult] ADD CONSTRAINT [PK_JCM_JobResult] PRIMARY KEY CLUSTERED  ([JobStepResultId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JCM_JobStepResult] ADD CONSTRAINT [FK_JCM_JobResult_JobStep] FOREIGN KEY ([JobStepId]) REFERENCES [dbo].[JCM_JobStep] ([JobStepId])
GO
ALTER TABLE [dbo].[JCM_JobStepResult] ADD CONSTRAINT [FK_JCM_JobResult_Name] FOREIGN KEY ([NameId]) REFERENCES [dbo].[JCM_Name] ([NameId])
GO
