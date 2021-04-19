CREATE TABLE [dbo].[CFG_History]
(
[HistoryId] [int] NOT NULL IDENTITY(1, 1),
[IVHIntId] [int] NOT NULL,
[KeyId] [int] NOT NULL,
[KeyValue] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[Status] [bit] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CFG_History_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CFG_History] ADD CONSTRAINT [PK_CFG_History] PRIMARY KEY CLUSTERED  ([HistoryId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CFG_History_VehicleEndDate] ON [dbo].[CFG_History] ([IVHIntId], [EndDate], [Status]) INCLUDE ([KeyId], [KeyValue], [StartDate]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CFG_History_VehicleKeyEndDate] ON [dbo].[CFG_History] ([IVHIntId], [KeyId], [EndDate], [Status]) INCLUDE ([KeyValue], [StartDate]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CFG_History_VehicleKeyDate] ON [dbo].[CFG_History] ([IVHIntId], [KeyId], [StartDate]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CFG_History_KeyEndDateStatus] ON [dbo].[CFG_History] ([KeyId], [EndDate], [Status]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CFG_History] ADD CONSTRAINT [FK_CFG_History_IVH] FOREIGN KEY ([IVHIntId]) REFERENCES [dbo].[IVH] ([IVHIntId])
GO
ALTER TABLE [dbo].[CFG_History] ADD CONSTRAINT [FK_CFG_History_Key] FOREIGN KEY ([KeyId]) REFERENCES [dbo].[CFG_Key] ([KeyId])
GO
