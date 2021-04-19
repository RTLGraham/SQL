CREATE TABLE [dbo].[KB_Assessment]
(
[AssessmentId] [int] NOT NULL IDENTITY(1, 1),
[FileId] [int] NOT NULL,
[Name] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PassScore] [smallint] NULL,
[Archived] [bit] NULL CONSTRAINT [DF_KB_Assessment_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_KB_Assessment_LastOperation] DEFAULT (getdate()),
[CustomerId] [uniqueidentifier] NULL,
[IsFeedbackRequired] [bit] NULL,
[IsEnabled] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_Assessment] ADD CONSTRAINT [PK_KB_Assessment] PRIMARY KEY CLUSTERED  ([AssessmentId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_Assessment] ADD CONSTRAINT [FK_KB_Assessment_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([CustomerId])
GO
ALTER TABLE [dbo].[KB_Assessment] ADD CONSTRAINT [FK_KB_Assessment_File] FOREIGN KEY ([FileId]) REFERENCES [dbo].[KB_File] ([FileId])
GO
