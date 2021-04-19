CREATE TABLE [dbo].[WidgetType]
(
[WidgetTypeID] [int] NOT NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_WidgetType_Archived] DEFAULT ((0)),
[NameId] [int] NULL,
[VideoGuidePath] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WidgetType] ADD CONSTRAINT [PK_WidgetType_1] PRIMARY KEY CLUSTERED  ([WidgetTypeID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_WidgetType] ON [dbo].[WidgetType] ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WidgetType] ADD CONSTRAINT [FK_WidgetType_NameId] FOREIGN KEY ([NameId]) REFERENCES [dbo].[DictionaryName] ([NameID])
GO
