CREATE TABLE [dbo].[TAN_TriggerEntityLatest]
(
[TriggerId] [uniqueidentifier] NOT NULL,
[TriggerEntityId] [uniqueidentifier] NOT NULL,
[LatestTriggerDateTime] [datetime] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_TAN_TrigEntLatest_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_TriggerEntityLatest] ADD CONSTRAINT [PK_TAN_TriggerEntityLatest] PRIMARY KEY CLUSTERED  ([TriggerId], [TriggerEntityId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_TriggerEntityLatest] WITH NOCHECK ADD CONSTRAINT [FK_TAN_TriggerEntityLatest_TriggerId] FOREIGN KEY ([TriggerId]) REFERENCES [dbo].[TAN_Trigger] ([TriggerId])
GO
