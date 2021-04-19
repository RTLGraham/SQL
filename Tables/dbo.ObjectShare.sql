CREATE TABLE [dbo].[ObjectShare]
(
[ObjectShareId] [int] NOT NULL IDENTITY(1, 1),
[ObjectId] [uniqueidentifier] NULL,
[ObjectIntId] [bigint] NULL,
[ObjectTypeId] [smallint] NULL,
[EntityId] [uniqueidentifier] NULL,
[EntityTypeId] [smallint] NULL,
[LastModifiedDateTime] [datetime] NULL,
[Archived] [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ObjectShare_Entity] ON [dbo].[ObjectShare] ([EntityId], [EntityTypeId], [Archived]) INCLUDE ([ObjectShareId], [ObjectId], [ObjectIntId], [ObjectTypeId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ObjectShare_ObjectId] ON [dbo].[ObjectShare] ([ObjectId], [ObjectTypeId], [Archived]) INCLUDE ([ObjectShareId], [EntityId], [EntityTypeId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ObjectShare_ObjectInt] ON [dbo].[ObjectShare] ([ObjectIntId], [ObjectTypeId], [Archived]) INCLUDE ([ObjectShareId], [EntityId], [EntityTypeId]) ON [PRIMARY]
GO
