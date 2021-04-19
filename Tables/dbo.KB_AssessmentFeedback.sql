CREATE TABLE [dbo].[KB_AssessmentFeedback]
(
[AssessmentFeedbackId] [int] NOT NULL IDENTITY(1, 1),
[AssessmentId] [int] NOT NULL,
[DriverIntId] [int] NOT NULL,
[FeedbackDateTime] [datetime] NOT NULL,
[AssessmentFeedbackText] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_KB_AssessmentFeedback_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_KB_AssessmentFeedback_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_AssessmentFeedback] ADD CONSTRAINT [PK_KB_AssessmentFeedback] PRIMARY KEY CLUSTERED  ([AssessmentFeedbackId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_AssessmentFeedback] ADD CONSTRAINT [FK_KB_AssessmentFeedback_Assessment] FOREIGN KEY ([AssessmentId]) REFERENCES [dbo].[KB_Assessment] ([AssessmentId])
GO
