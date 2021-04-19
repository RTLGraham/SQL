CREATE TABLE [dbo].[UserWidgetTemplate]
(
[UserID] [uniqueidentifier] NOT NULL,
[WidgetTemplateID] [uniqueidentifier] NOT NULL,
[Archived] [bit] NULL CONSTRAINT [DF_UserWidgetTemplate_Archived] DEFAULT ((0)),
[UsageCount] [int] NULL CONSTRAINT [DF_UserWidgetTemplate_UsageCount] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserWidgetTemplate] ADD CONSTRAINT [PK_UserWidgetTemplate] PRIMARY KEY CLUSTERED  ([UserID], [WidgetTemplateID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserWidgetTemplate] ADD CONSTRAINT [FK_UserWidget_WidgetTemplate] FOREIGN KEY ([WidgetTemplateID]) REFERENCES [dbo].[WidgetTemplate] ([WidgetTemplateID])
GO
ALTER TABLE [dbo].[UserWidgetTemplate] ADD CONSTRAINT [FK_UserWidgetTemplate_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User] ([UserID])
GO
