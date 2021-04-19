CREATE TABLE [dbo].[TAN_Trigger]
(
[TriggerId] [uniqueidentifier] NOT NULL,
[TriggerTypeId] [int] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Disabled] [bit] NOT NULL CONSTRAINT [DF__TAN_Trigg__Disab__7C9038FD] DEFAULT ((0)),
[Archived] [bit] NOT NULL CONSTRAINT [DF__TAN_Trigg__Archi__7D845D36] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF__TAN_Trigg__LastO__7E78816F] DEFAULT (getdate()),
[CustomerId] [uniqueidentifier] NOT NULL,
[CreatedBy] [uniqueidentifier] NOT NULL,
[Count] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_Trigger] ADD CONSTRAINT [PK_TAN_Trigger] PRIMARY KEY CLUSTERED  ([TriggerId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_Trigger] ADD CONSTRAINT [FK_TAN_Trigger_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([CustomerId])
GO
ALTER TABLE [dbo].[TAN_Trigger] WITH NOCHECK ADD CONSTRAINT [FK_TAN_Trigger_TriggerTypeId] FOREIGN KEY ([TriggerTypeId]) REFERENCES [dbo].[TAN_TriggerType] ([TriggerTypeId])
GO
