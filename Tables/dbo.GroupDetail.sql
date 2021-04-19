CREATE TABLE [dbo].[GroupDetail]
(
[GroupId] [uniqueidentifier] NOT NULL,
[GroupTypeId] [int] NOT NULL,
[EntityDataId] [uniqueidentifier] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GroupDetail] ADD CONSTRAINT [PK_GroupDetail] PRIMARY KEY CLUSTERED  ([GroupId], [GroupTypeId], [EntityDataId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GroupDetail_GroupTypeEntity] ON [dbo].[GroupDetail] ([GroupTypeId], [EntityDataId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GroupDetail] ADD CONSTRAINT [FK_GroupDetail_Group] FOREIGN KEY ([GroupId]) REFERENCES [dbo].[Group] ([GroupId])
GO
ALTER TABLE [dbo].[GroupDetail] ADD CONSTRAINT [FK_GroupDetail_GroupType] FOREIGN KEY ([GroupTypeId]) REFERENCES [dbo].[GroupType] ([GroupTypeId])
GO
