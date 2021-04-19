CREATE TABLE [dbo].[TAN_TriggerEvent]
(
[TriggerEventId] [uniqueidentifier] NOT NULL,
[CreationCodeId] [smallint] NOT NULL,
[EventId] [bigint] NULL,
[CustomerIntId] [int] NOT NULL,
[VehicleIntID] [int] NULL,
[DriverIntId] [int] NULL,
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
[ProcessInd] [smallint] NOT NULL CONSTRAINT [DF__TAN_Trigg__Proce__638F8109] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF__TAN_Trigg__LastO__6483A542] DEFAULT (getdate()),
[GeofenceId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_TriggerEvent] ADD CONSTRAINT [PK_TAN_TriggerEvent] PRIMARY KEY CLUSTERED  ([TriggerEventId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TAN_TriggerEvent_CreationCodeProcessInd] ON [dbo].[TAN_TriggerEvent] ([CreationCodeId], [ProcessInd]) INCLUDE ([TriggerEventId], [EventId], [CustomerIntId], [VehicleIntID], [DriverIntId], [ApplicationId], [Long], [Lat], [Heading], [Speed], [TripDistance], [DataName], [DataString], [DataInt], [DataFloat], [DataBit], [TriggerDateTime], [GeofenceId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TAN_TriggerEvent_ProcessInd] ON [dbo].[TAN_TriggerEvent] ([ProcessInd]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_TAN_TriggerEvent_VehicleCreationProcessInd] ON [dbo].[TAN_TriggerEvent] ([VehicleIntID], [CreationCodeId], [ProcessInd]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TAN_TriggerEvent] ADD CONSTRAINT [FK_TAN_TriggerEvent_CreationCode] FOREIGN KEY ([CreationCodeId]) REFERENCES [dbo].[CreationCode] ([CreationCodeId])
GO
ALTER TABLE [dbo].[TAN_TriggerEvent] ADD CONSTRAINT [FK_TAN_TriggerEvent_Customer] FOREIGN KEY ([CustomerIntId]) REFERENCES [dbo].[Customer] ([CustomerIntId])
GO
ALTER TABLE [dbo].[TAN_TriggerEvent] ADD CONSTRAINT [FK_TAN_TriggerEvent_Driver] FOREIGN KEY ([DriverIntId]) REFERENCES [dbo].[Driver] ([DriverIntId])
GO
ALTER TABLE [dbo].[TAN_TriggerEvent] ADD CONSTRAINT [FK_TAN_TriggerEvent_Vehicle] FOREIGN KEY ([VehicleIntID]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
