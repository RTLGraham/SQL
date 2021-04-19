CREATE TABLE [dbo].[KB_Question]
(
[QuestionId] [int] NOT NULL IDENTITY(1, 1),
[CategoryId] [int] NOT NULL,
[QuestionText] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OptionA] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsACorrect] [bit] NULL,
[OptionB] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsBCorrect] [bit] NULL,
[OptionC] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsCCorrect] [bit] NULL,
[OptionD] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsDCorrect] [bit] NULL,
[Archived] [bit] NULL CONSTRAINT [DF_KB_Question_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_KB_Question_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_Question] ADD CONSTRAINT [PK_KB_Question] PRIMARY KEY CLUSTERED  ([QuestionId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_Question] ADD CONSTRAINT [FK_KB_Question_Category] FOREIGN KEY ([CategoryId]) REFERENCES [dbo].[KB_Category] ([CategoryId])
GO
