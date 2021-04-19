CREATE TABLE [dbo].[TAN_EntityCheckOut]
(
[EntityCheckOutId] [int] NOT NULL IDENTITY(1, 1),
[EntityId] [uniqueidentifier] NOT NULL,
[CheckOutDateTime] [datetime] NOT NULL,
[CheckInDateTime] [datetime] NOT NULL,
[CheckOutUserId] [uniqueidentifier] NOT NULL,
[CheckInUserId] [uniqueidentifier] NULL,
[CheckOutReason] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AnalogData0] [smallint] NULL,
[AnalogData1] [smallint] NULL,
[AnalogData2] [smallint] NULL,
[AnalogData3] [smallint] NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_TAN_EntityCheckOut_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_TAN_EntityCheckOut_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_EntityCheckOut] ADD CONSTRAINT [PK_TAN_EntityCheckOut] PRIMARY KEY CLUSTERED  ([EntityCheckOutId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TAN_EntityCheckout_EntityDate] ON [dbo].[TAN_EntityCheckOut] ([EntityId], [CheckOutDateTime]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
