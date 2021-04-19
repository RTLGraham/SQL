CREATE TABLE [dbo].[DGenCharData]
(
[DGenCharDataId] [int] NOT NULL IDENTITY(1, 1),
[DGenId] [int] NULL,
[RowIndex] [int] NULL,
[ColIndex] [int] NULL,
[TimeVal] [int] NULL,
[Distance] [float] NULL,
[Fuel] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DGenCharData] ADD CONSTRAINT [PK_DGenCharData] PRIMARY KEY CLUSTERED  ([DGenCharDataId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
