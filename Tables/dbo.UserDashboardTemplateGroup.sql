CREATE TABLE [dbo].[UserDashboardTemplateGroup]
(
[UserDashboardTemplateID] [int] NOT NULL,
[GroupID] [uniqueidentifier] NOT NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_UserDashboardTemplateGroup_Archived] DEFAULT ((0)),
[LastModified] [datetime] NOT NULL CONSTRAINT [DF_UserDashboardTemplateGroup_LastModified] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserDashboardTemplateGroup] ADD CONSTRAINT [PK_UserDashboardTemplateGroup] PRIMARY KEY CLUSTERED  ([UserDashboardTemplateID], [GroupID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserDashboardTemplateGroup] ADD CONSTRAINT [FK_UserDashboardTemplateGroup_Group] FOREIGN KEY ([GroupID]) REFERENCES [dbo].[Group] ([GroupId])
GO
ALTER TABLE [dbo].[UserDashboardTemplateGroup] ADD CONSTRAINT [FK_UserDashboardTemplateGroup_UserDashboardTemplate] FOREIGN KEY ([UserDashboardTemplateID]) REFERENCES [dbo].[UserDashboardTemplate] ([UserDashboardTemplateID])
GO
