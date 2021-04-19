CREATE TABLE [dbo].[ReportTranslationSet]
(
[SetID] [int] NOT NULL IDENTITY(1, 1),
[WidgetTypeID] [int] NOT NULL,
[Culture] [nchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportTranslationSet] ADD CONSTRAINT [PK__ReportTr__7E08473C3227E1C9] PRIMARY KEY NONCLUSTERED  ([SetID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_ReportTranslationSet] ON [dbo].[ReportTranslationSet] ([WidgetTypeID], [Culture]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportTranslationSet] ADD CONSTRAINT [FK__ReportTra__Widge__5868B277] FOREIGN KEY ([WidgetTypeID]) REFERENCES [dbo].[WidgetType] ([WidgetTypeID])
GO
