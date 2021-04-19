CREATE TABLE [dbo].[GroupTypeTables]
(
[GroupTypeId] [int] NOT NULL,
[EntityTableName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EntityTablePrimaryKey] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EntityProc] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GroupTypeTables] ADD CONSTRAINT [PK_GroupTypeTables_1] PRIMARY KEY CLUSTERED  ([GroupTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GroupTypeTables] ADD CONSTRAINT [FK_GroupTypeTables_GroupType] FOREIGN KEY ([GroupTypeId]) REFERENCES [dbo].[GroupType] ([GroupTypeId])
GO
