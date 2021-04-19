CREATE TABLE [dbo].[TAN_TriggerType]
(
[TriggerTypeId] [int] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreationCodeId] [smallint] NOT NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF__TAN_Trigg__Archi__78BFA819] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF__TAN_Trigg__LastO__79B3CC52] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_TriggerType] ADD CONSTRAINT [PK_TAN_TriggerType] PRIMARY KEY CLUSTERED  ([TriggerTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TAN_TriggerType] ON [dbo].[TAN_TriggerType] ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
