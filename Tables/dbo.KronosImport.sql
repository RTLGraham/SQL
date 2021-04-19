CREATE TABLE [dbo].[KronosImport]
(
[KronosImportId] [int] NOT NULL IDENTITY(1, 1),
[DataDispatcher] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InsertDateTime] [datetime] NOT NULL,
[KronosFileName] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Records] [int] NULL,
[SecondsTotal] [int] NULL,
[SecondsExchange] [int] NULL,
[SecondsDownload] [int] NULL,
[SecondsParse] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KronosImport] ADD CONSTRAINT [PK_KronosImport] PRIMARY KEY CLUSTERED  ([KronosImportId]) WITH (IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
