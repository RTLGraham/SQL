CREATE TABLE [dbo].[Category]
(
[CategoryID] [int] NOT NULL IDENTITY(1, 1),
[CategoryName] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Category] ADD CONSTRAINT [PK_Categories] PRIMARY KEY CLUSTERED  ([CategoryID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
