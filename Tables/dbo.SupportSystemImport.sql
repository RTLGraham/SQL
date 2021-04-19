CREATE TABLE [dbo].[SupportSystemImport]
(
[SupportSystemImportId] [int] NOT NULL IDENTITY(1, 1),
[DataDispatcher] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[InsertDateTime] [datetime] NOT NULL,
[SupportSystemFileName] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Records] [int] NULL,
[SecondsTotal] [int] NULL,
[SecondsExchange] [int] NULL,
[SecondsDownload] [int] NULL,
[SecondsParse] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupportSystemImport] ADD CONSTRAINT [PK_SupportSystemImport] PRIMARY KEY CLUSTERED  ([SupportSystemImportId]) WITH (IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
