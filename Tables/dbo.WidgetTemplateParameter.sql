CREATE TABLE [dbo].[WidgetTemplateParameter]
(
[WidgetTemplateParameterID] [uniqueidentifier] NOT NULL CONSTRAINT [DF_WidgetTemplateParameter_WidgetTemplateParameterID] DEFAULT (newid()),
[WidgetTemplateID] [uniqueidentifier] NULL,
[NameID] [int] NOT NULL,
[Value] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_WidgetTemplateParameter_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WidgetTemplateParameter] ADD CONSTRAINT [PK_WidgetTemplateParameter_1] PRIMARY KEY CLUSTERED  ([WidgetTemplateParameterID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WidgetTemplateParameter] ADD CONSTRAINT [FK_WidgetTemplateParameter_DictionaryName] FOREIGN KEY ([NameID]) REFERENCES [dbo].[DictionaryName] ([NameID])
GO
ALTER TABLE [dbo].[WidgetTemplateParameter] ADD CONSTRAINT [FK_WidgetTemplateParameter_WidgetTemplate] FOREIGN KEY ([WidgetTemplateID]) REFERENCES [dbo].[WidgetTemplate] ([WidgetTemplateID])
GO
