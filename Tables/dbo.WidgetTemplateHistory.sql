CREATE TABLE [dbo].[WidgetTemplateHistory]
(
[WidgetTemplateHistoryID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_WidgetTemplateHistory_WidgetTemplateHistoryID] DEFAULT (newid()),
[WidgetTemplateID] [uniqueidentifier] NOT NULL,
[DateClosed] [datetime] NOT NULL,
[UserID] [uniqueidentifier] NOT NULL,
[Archived] [bit] NULL CONSTRAINT [DF_WidgetTemplateHistory_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WidgetTemplateHistory] ADD CONSTRAINT [PK_WidgetTemplateHistory] PRIMARY KEY CLUSTERED  ([WidgetTemplateHistoryID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WidgetTemplateHistory] ADD CONSTRAINT [FK_WidgetTemplateHistory_User] FOREIGN KEY ([UserID]) REFERENCES [dbo].[User] ([UserID])
GO
ALTER TABLE [dbo].[WidgetTemplateHistory] ADD CONSTRAINT [FK_WidgetTemplateHistory_WidgetTemplate] FOREIGN KEY ([WidgetTemplateID]) REFERENCES [dbo].[WidgetTemplate] ([WidgetTemplateID])
GO
