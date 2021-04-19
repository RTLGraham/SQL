CREATE TABLE [dbo].[TAN_TriggerSchedule]
(
[TriggerId] [uniqueidentifier] NOT NULL,
[DayNum] [smallint] NOT NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF__TAN_Trigg__Archi__118B55E3] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF__TAN_Trigg__LastO__127F7A1C] DEFAULT (getdate()),
[Count] [bigint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_TriggerSchedule] ADD CONSTRAINT [PK_TAN_TriggerSchedule] PRIMARY KEY CLUSTERED  ([TriggerId], [DayNum]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_TriggerSchedule] WITH NOCHECK ADD CONSTRAINT [FK_TAN_TriggerSchedule_TriggerId] FOREIGN KEY ([TriggerId]) REFERENCES [dbo].[TAN_Trigger] ([TriggerId])
GO
