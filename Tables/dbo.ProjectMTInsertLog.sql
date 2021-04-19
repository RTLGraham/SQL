CREATE TABLE [dbo].[ProjectMTInsertLog]
(
[ProjectMTnsertLogId] [bigint] NOT NULL IDENTITY(1, 1),
[ProjectMTId] [int] NOT NULL,
[TripCount] [int] NULL,
[NewDriverCount] [int] NULL,
[LastIdPrev] [int] NULL,
[LastIdNew] [int] NULL,
[MilliSecondsTotal] [int] NULL,
[InsertDateTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProjectMTInsertLog] ADD CONSTRAINT [PK_ProjectMTInsertLog] PRIMARY KEY CLUSTERED  ([ProjectMTnsertLogId]) WITH (IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProjectMTInsertLog] ADD CONSTRAINT [FK_ProjectMTInsertLog_ProjectMT] FOREIGN KEY ([ProjectMTId]) REFERENCES [dbo].[ProjectMT] ([ProjectMTId])
GO
