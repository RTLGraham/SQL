CREATE TABLE [dbo].[Group]
(
[GroupId] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Group_GroupId] DEFAULT (newid()),
[GroupName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupTypeId] [int] NOT NULL,
[IsParameter] [bit] NULL CONSTRAINT [DF_Group_IsParameter] DEFAULT ((0)),
[Archived] [bit] NULL CONSTRAINT [DF_Group_Archived] DEFAULT ((0)),
[LastModified] [datetime] NULL CONSTRAINT [DF_Group_LastModified] DEFAULT (getdate()),
[OriginalGroupId] [uniqueidentifier] NULL,
[IsPhysical] [bit] NULL,
[GeofenceId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Group] ADD CONSTRAINT [PK_Group] PRIMARY KEY CLUSTERED  ([GroupId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Group_GroupTypeParameter] ON [dbo].[Group] ([GroupTypeId], [IsParameter], [Archived]) INCLUDE ([GroupId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Group] ADD CONSTRAINT [FK_Group_GroupType] FOREIGN KEY ([GroupTypeId]) REFERENCES [dbo].[GroupType] ([GroupTypeId])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Set to true if this is a ''temporary'' group set up as part of a widget template parameter setting.', 'SCHEMA', N'dbo', 'TABLE', N'Group', 'COLUMN', N'IsParameter'
GO
