CREATE TABLE [dbo].[WidgetTemplate]
(
[WidgetTemplateID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_WidgetTemplate_WidgetTemplateID] DEFAULT (newid()),
[WidgetTypeID] [int] NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ThumbnailRelativePath] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_WidgetTemplate_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WidgetTemplate] ADD CONSTRAINT [PK_WidgetTemplate] PRIMARY KEY CLUSTERED  ([WidgetTemplateID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WidgetTemplate] ADD CONSTRAINT [FK_WidgetTemplate_WidgetType] FOREIGN KEY ([WidgetTypeID]) REFERENCES [dbo].[WidgetType] ([WidgetTypeID])
GO
