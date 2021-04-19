CREATE TABLE [dbo].[GroupType]
(
[GroupTypeId] [int] NOT NULL,
[GroupTypeName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GroupTypeDescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GroupType] ADD CONSTRAINT [PK_GroupType] PRIMARY KEY CLUSTERED  ([GroupTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GroupTypeName] ON [dbo].[GroupType] ([GroupTypeName]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
