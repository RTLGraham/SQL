CREATE TABLE [dbo].[KB_FeedbackQuestion]
(
[FeedbackQuestionId] [int] NOT NULL,
[FeedbackQuestionText] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptionA] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptionB] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptionC] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptionD] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_KB_FeedbackQuestion_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_KB_FeedbackQuestion_LastOperation] DEFAULT (getdate()),
[Culture] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Position] [int] NULL,
[QuestionId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_FeedbackQuestion] ADD CONSTRAINT [PK_KB_FeedbackQuestion] PRIMARY KEY CLUSTERED  ([FeedbackQuestionId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
