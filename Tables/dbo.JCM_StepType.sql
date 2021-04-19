CREATE TABLE [dbo].[JCM_StepType]
(
[StepTypeId] [int] NOT NULL,
[Name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_StepType_Arc] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_StepType_LastOp] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JCM_StepType] ADD CONSTRAINT [PK_JCM_StepType] PRIMARY KEY CLUSTERED  ([StepTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
