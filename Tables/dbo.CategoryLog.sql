CREATE TABLE [dbo].[CategoryLog]
(
[CategoryLogID] [int] NOT NULL IDENTITY(1, 1),
[CategoryID] [int] NOT NULL,
[LogID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CategoryLog] ADD CONSTRAINT [PK_CategoryLog] PRIMARY KEY CLUSTERED  ([CategoryLogID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ixCategoryLog] ON [dbo].[CategoryLog] ([LogID], [CategoryID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CategoryLog] ADD CONSTRAINT [FK_CategoryLog_Category] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[Category] ([CategoryID])
GO
ALTER TABLE [dbo].[CategoryLog] ADD CONSTRAINT [FK_CategoryLog_Log] FOREIGN KEY ([LogID]) REFERENCES [dbo].[Log] ([LogID])
GO
