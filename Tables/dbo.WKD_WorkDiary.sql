CREATE TABLE [dbo].[WKD_WorkDiary]
(
[WorkDiaryId] [int] NOT NULL IDENTITY(1, 1),
[DriverIntId] [int] NOT NULL,
[StartDate] [datetime] NOT NULL,
[Number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EndDate] [datetime] NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_WKD_WorkDiary_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_WKD_WorkDiary_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WKD_WorkDiary] ADD CONSTRAINT [PK_WKD_WorkDiary] PRIMARY KEY CLUSTERED  ([WorkDiaryId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WKD_WorkDiary_Driver] ON [dbo].[WKD_WorkDiary] ([DriverIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WKD_WorkDiary] ADD CONSTRAINT [FK_WKD_WorkDiary_Driver] FOREIGN KEY ([DriverIntId]) REFERENCES [dbo].[Driver] ([DriverIntId])
GO
