CREATE TABLE [dbo].[CharacteristicsMatrix]
(
[CharMatrixId] [int] NOT NULL IDENTITY(1, 1),
[Config] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NumRows] [int] NULL,
[NumCols] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CharacteristicsMatrix] ADD CONSTRAINT [PK_CharacteristicsMetaDataType] PRIMARY KEY CLUSTERED  ([CharMatrixId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
