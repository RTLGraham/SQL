CREATE TABLE [dbo].[WKD_WorkDiaryPage]
(
[WorkDiaryPageId] [int] NOT NULL IDENTITY(1, 1),
[WorkDiaryId] [int] NOT NULL,
[Date] [smalldatetime] NOT NULL,
[DriverSignature] [varbinary] (max) NULL,
[SignDate] [datetime] NULL,
[TwoUpWorkDiaryPageId] [int] NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_WKD_WorkDiaryPage_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_WKD_WorkDiaryPage_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WKD_WorkDiaryPage] ADD CONSTRAINT [PK_WKD_WorkDiaryPage] PRIMARY KEY CLUSTERED  ([WorkDiaryPageId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WorkDiaryPage_WorkDiaryDate] ON [dbo].[WKD_WorkDiaryPage] ([WorkDiaryId], [Date]) INCLUDE ([TwoUpWorkDiaryPageId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WKD_WorkDiaryPage] ADD CONSTRAINT [FK_WKD_WorkDiaryPage_TwoUp] FOREIGN KEY ([TwoUpWorkDiaryPageId]) REFERENCES [dbo].[WKD_WorkDiaryPage] ([WorkDiaryPageId])
GO
ALTER TABLE [dbo].[WKD_WorkDiaryPage] ADD CONSTRAINT [FK_WKD_WorkDiaryPage_WorkDiary] FOREIGN KEY ([WorkDiaryId]) REFERENCES [dbo].[WKD_WorkDiary] ([WorkDiaryId])
GO
