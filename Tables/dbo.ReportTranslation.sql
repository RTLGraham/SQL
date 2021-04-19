CREATE TABLE [dbo].[ReportTranslation]
(
[TranslationID] [int] NOT NULL IDENTITY(1, 1),
[SetID] [int] NOT NULL,
[Key] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportTranslation] ADD CONSTRAINT [PK__ReportTr__663DA0AC68875E96] PRIMARY KEY CLUSTERED  ([TranslationID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportTranslation] ADD CONSTRAINT [FK__ReportTra__SetID__57748E3E] FOREIGN KEY ([SetID]) REFERENCES [dbo].[ReportTranslationSet] ([SetID])
GO
