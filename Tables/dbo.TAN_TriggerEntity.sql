CREATE TABLE [dbo].[TAN_TriggerEntity]
(
[TriggerId] [uniqueidentifier] NOT NULL,
[TriggerEntityId] [uniqueidentifier] NOT NULL,
[Disabled] [bit] NOT NULL CONSTRAINT [DF__TAN_Trigg__Disab__0CC6A0C6] DEFAULT ((0)),
[Archived] [bit] NOT NULL CONSTRAINT [DF__TAN_Trigg__Archi__0DBAC4FF] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF__TAN_Trigg__LastO__0EAEE938] DEFAULT (getdate()),
[Count] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_TriggerEntity] ADD CONSTRAINT [PK_TAN_TriggerEntity] PRIMARY KEY CLUSTERED  ([TriggerId], [TriggerEntityId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_TriggerEntity] WITH NOCHECK ADD CONSTRAINT [FK_TAN_TriggerEntity_TriggerId] FOREIGN KEY ([TriggerId]) REFERENCES [dbo].[TAN_Trigger] ([TriggerId])
GO
