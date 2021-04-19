CREATE TABLE [dbo].[UserGroup]
(
[UserId] [uniqueidentifier] NOT NULL,
[GroupId] [uniqueidentifier] NOT NULL,
[Archived] [bit] NULL CONSTRAINT [DF_UserGroup_Archived] DEFAULT ((0)),
[LastModified] [datetime] NULL CONSTRAINT [DF_UserGroup_LastModified] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserGroup] ADD CONSTRAINT [PK_UserGroup] PRIMARY KEY CLUSTERED  ([UserId], [GroupId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UserGroup_GroupId] ON [dbo].[UserGroup] ([GroupId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserGroup] ADD CONSTRAINT [FK_UserGroup_Group] FOREIGN KEY ([GroupId]) REFERENCES [dbo].[Group] ([GroupId])
GO
ALTER TABLE [dbo].[UserGroup] ADD CONSTRAINT [FK_UserGroup_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserID])
GO
