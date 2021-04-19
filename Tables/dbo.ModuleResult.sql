CREATE TABLE [dbo].[ModuleResult]
(
[UserID] [uniqueidentifier] NOT NULL,
[ModuleID] [int] NOT NULL,
[Timestamp] [datetime] NOT NULL,
[Completed] [bit] NOT NULL,
[CourseID] [int] NOT NULL,
[Duration] [int] NOT NULL,
[Score] [float] NOT NULL,
[Correct] [int] NOT NULL,
[Incorrect] [int] NOT NULL,
[Status] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PageIndex] [int] NOT NULL,
[PageData] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FeedbackData] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RawData] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModuleResult] ADD CONSTRAINT [PK_ModuleResult] PRIMARY KEY CLUSTERED  ([UserID], [ModuleID], [Timestamp]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ModuleResult] ADD CONSTRAINT [FK_ModuleResult_Module] FOREIGN KEY ([ModuleID]) REFERENCES [dbo].[Module] ([ModuleID])
GO
ALTER TABLE [dbo].[ModuleResult] ADD CONSTRAINT [FK_ModuleResult_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User] ([UserID])
GO
