CREATE TABLE [dbo].[TAN_TriggerParam]
(
[TriggerId] [uniqueidentifier] NOT NULL,
[TriggerParamTypeId] [int] NOT NULL,
[TriggerParamTypeValue] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF__TAN_Trigg__Archi__08F60FE2] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF__TAN_Trigg__LastO__09EA341B] DEFAULT (getdate()),
[Count] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_TriggerParam] ADD CONSTRAINT [PK_TAN_TriggerParam] PRIMARY KEY CLUSTERED  ([TriggerId], [TriggerParamTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_TriggerParam] WITH NOCHECK ADD CONSTRAINT [FK_TAN_TriggerParam_TriggerId] FOREIGN KEY ([TriggerId]) REFERENCES [dbo].[TAN_Trigger] ([TriggerId])
GO
ALTER TABLE [dbo].[TAN_TriggerParam] WITH NOCHECK ADD CONSTRAINT [FK_TAN_TriggerParam_TriggerParamTypeId] FOREIGN KEY ([TriggerParamTypeId]) REFERENCES [dbo].[TAN_TriggerParamType] ([TriggerParamTypeId])
GO
