CREATE TABLE [dbo].[JCM_JobStep]
(
[JobStepId] [int] NOT NULL IDENTITY(1, 1),
[JobId] [int] NOT NULL,
[StepNum] [tinyint] NOT NULL,
[Title] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StepTypeId] [int] NOT NULL,
[Lat] [float] NULL,
[Lon] [float] NULL,
[Image] [varbinary] (max) NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_JobStep_Arc] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_JobStep_LastOp] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JCM_JobStep] ADD CONSTRAINT [PK_JCM_JobStep] PRIMARY KEY CLUSTERED  ([JobStepId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JCM_JobStep] ADD CONSTRAINT [FK_JCM_JobStep_Job] FOREIGN KEY ([JobId]) REFERENCES [dbo].[JCM_Job] ([JobId])
GO
ALTER TABLE [dbo].[JCM_JobStep] ADD CONSTRAINT [FK_JCM_JobStep_StepType] FOREIGN KEY ([StepTypeId]) REFERENCES [dbo].[JCM_StepType] ([StepTypeId])
GO
