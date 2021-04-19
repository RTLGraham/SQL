CREATE TABLE [dbo].[KB_AssessmentFeedbackDetail]
(
[AssessmentFeedbackDetailId] [int] NOT NULL IDENTITY(1, 1),
[AssessmentFeedbackId] [int] NOT NULL,
[FeedbackQuestionId] [int] NOT NULL,
[Response] [tinyint] NULL,
[Archived] [bit] NULL CONSTRAINT [DF_KB_AssessmentFeedbackDetail_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_KB_AssessmentFeedbackDetail_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_AssessmentFeedbackDetail] ADD CONSTRAINT [PK_KB_AssessmentFeedbackDetail] PRIMARY KEY CLUSTERED  ([AssessmentFeedbackDetailId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_AssessmentFeedbackDetail] ADD CONSTRAINT [FK_KB_AssessmentFeedbackDetail_AssessmentFeedback] FOREIGN KEY ([AssessmentFeedbackId]) REFERENCES [dbo].[KB_AssessmentFeedback] ([AssessmentFeedbackId])
GO
ALTER TABLE [dbo].[KB_AssessmentFeedbackDetail] ADD CONSTRAINT [FK_KB_AssessmentFeedbackDetail_FeedbackQuestion] FOREIGN KEY ([FeedbackQuestionId]) REFERENCES [dbo].[KB_FeedbackQuestion] ([FeedbackQuestionId])
GO
