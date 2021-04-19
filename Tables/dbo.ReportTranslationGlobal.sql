CREATE TABLE [dbo].[ReportTranslationGlobal]
(
[ReportTranslationGlobalID] [int] NOT NULL IDENTITY(1, 1),
[Key] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Value] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportTranslationGlobal] ADD CONSTRAINT [PK__ReportTr__276AC20DF5372A8B] PRIMARY KEY CLUSTERED  ([ReportTranslationGlobalID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
