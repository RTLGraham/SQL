CREATE TABLE [dbo].[TAN_TriggerParamType]
(
[TriggerParamTypeId] [int] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF__TAN_Trigg__Archi__05257EFE] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF__TAN_Trigg__LastO__0619A337] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_TriggerParamType] ADD CONSTRAINT [PK_TAN_TriggerParamType] PRIMARY KEY CLUSTERED  ([TriggerParamTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TAN_TriggerParamType] ON [dbo].[TAN_TriggerParamType] ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
