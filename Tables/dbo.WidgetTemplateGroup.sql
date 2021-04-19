CREATE TABLE [dbo].[WidgetTemplateGroup]
(
[GroupId] [uniqueidentifier] NOT NULL,
[WidgetTemplateId] [uniqueidentifier] NOT NULL,
[Archived] [bit] NULL CONSTRAINT [DF_WidgetTemplateGroup_Archived] DEFAULT ((0)),
[LastModified] [datetime] NULL CONSTRAINT [DF_WidgetTemplateGroup_LastModified] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WidgetTemplateGroup] ADD CONSTRAINT [PK_WidgetTemplateGroup] PRIMARY KEY CLUSTERED  ([GroupId], [WidgetTemplateId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WidgetTemplateGroup] ADD CONSTRAINT [FK_WidgetTemplateGroup_Group] FOREIGN KEY ([GroupId]) REFERENCES [dbo].[Group] ([GroupId])
GO
ALTER TABLE [dbo].[WidgetTemplateGroup] ADD CONSTRAINT [FK_WidgetTemplateGroup_WidgetTemplate] FOREIGN KEY ([WidgetTemplateId]) REFERENCES [dbo].[WidgetTemplate] ([WidgetTemplateID])
GO
