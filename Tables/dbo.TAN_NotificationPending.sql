CREATE TABLE [dbo].[TAN_NotificationPending]
(
[NotificationId] [uniqueidentifier] NOT NULL,
[TriggerId] [uniqueidentifier] NULL,
[NotificationTemplateId] [uniqueidentifier] NOT NULL,
[VehicleId] [uniqueidentifier] NULL,
[DriverId] [uniqueidentifier] NULL,
[ApplicationId] [smallint] NULL,
[Long] [float] NULL,
[Lat] [float] NULL,
[Heading] [smallint] NULL,
[Speed] [smallint] NULL,
[TripDistance] [int] NULL,
[DataName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataString] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataInt] [int] NULL,
[DataFloat] [float] NULL,
[DataBit] [bit] NULL,
[TriggerDateTime] [datetime] NULL,
[ProcessInd] [smallint] NOT NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF__TAN_Notif__Archi__7232A61B] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF__TAN_Notif__LastO__7326CA54] DEFAULT (getdate()),
[RecipientName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GeofenceId] [uniqueidentifier] NULL,
[EventId] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_NotificationPending] ADD CONSTRAINT [PK_TAN_NotificationPending] PRIMARY KEY CLUSTERED  ([NotificationId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TAN_NotificationPending_ProcessInd] ON [dbo].[TAN_NotificationPending] ([ProcessInd]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TAN_NotificationPending_Date] ON [dbo].[TAN_NotificationPending] ([TriggerDateTime]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TAN_NotificationPending_VehicleDate] ON [dbo].[TAN_NotificationPending] ([VehicleId], [TriggerDateTime]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_NotificationPending] ADD CONSTRAINT [FK_TAN_NotificationPending_Driver] FOREIGN KEY ([DriverId]) REFERENCES [dbo].[Driver] ([DriverId])
GO
ALTER TABLE [dbo].[TAN_NotificationPending] ADD CONSTRAINT [FK_TAN_NotificationPending_TAN_NotificationTemplate] FOREIGN KEY ([NotificationTemplateId]) REFERENCES [dbo].[TAN_NotificationTemplate] ([NotificationTemplateId])
GO
ALTER TABLE [dbo].[TAN_NotificationPending] ADD CONSTRAINT [FK_TAN_NotificationPending_TAN_Trigger] FOREIGN KEY ([TriggerId]) REFERENCES [dbo].[TAN_Trigger] ([TriggerId])
GO
ALTER TABLE [dbo].[TAN_NotificationPending] ADD CONSTRAINT [FK_TAN_NotificationPending_Vehicle] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
