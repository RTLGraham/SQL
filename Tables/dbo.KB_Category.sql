CREATE TABLE [dbo].[KB_Category]
(
[CategoryId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_KB_Category_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_KB_Category_LastOperation] DEFAULT (getdate()),
[AssessmentId] [int] NULL,
[NumQuestions] [smallint] NULL,
[CustomerId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_Category] ADD CONSTRAINT [PK_KB_Category] PRIMARY KEY CLUSTERED  ([CategoryId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_Category] ADD CONSTRAINT [FK_KB_Category_Assessment] FOREIGN KEY ([AssessmentId]) REFERENCES [dbo].[KB_Assessment] ([AssessmentId])
GO
ALTER TABLE [dbo].[KB_Category] ADD CONSTRAINT [FK_KB_Category_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([CustomerId])
GO
