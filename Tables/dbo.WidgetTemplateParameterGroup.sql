CREATE TABLE [dbo].[WidgetTemplateParameterGroup]
(
[WidgetTemplateID] [uniqueidentifier] NOT NULL,
[GroupID] [uniqueidentifier] NOT NULL,
[GroupTypeID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WidgetTemplateParameterGroup] ADD CONSTRAINT [PK_WidgetTemplateParameterGroup_1] PRIMARY KEY CLUSTERED  ([WidgetTemplateID], [GroupID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WidgetTemplateParameterGroup] ADD CONSTRAINT [FK_WidgetTemplateParameterGroup_Group] FOREIGN KEY ([GroupID]) REFERENCES [dbo].[Group] ([GroupId])
GO
ALTER TABLE [dbo].[WidgetTemplateParameterGroup] WITH NOCHECK ADD CONSTRAINT [FK_WidgetTemplateParameterGroup_GroupType] FOREIGN KEY ([GroupTypeID]) REFERENCES [dbo].[GroupType] ([GroupTypeId])
GO
ALTER TABLE [dbo].[WidgetTemplateParameterGroup] ADD CONSTRAINT [FK_WidgetTemplateParameterGroup_WidgetTemplate] FOREIGN KEY ([WidgetTemplateID]) REFERENCES [dbo].[WidgetTemplate] ([WidgetTemplateID])
GO
