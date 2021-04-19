CREATE TABLE [dbo].[MessagingEventData]
(
[EventDataId] [bigint] NOT NULL,
[EventDataName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDataString] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDataInt] [int] NULL,
[EventDataFloat] [float] NULL,
[EventDataBit] [bit] NULL,
[LastOperation] [smalldatetime] NULL,
[Archived] [bit] NULL,
[CreationCodeId] [smallint] NULL,
[CustomerIntId] [int] NULL,
[VehicleIntId] [int] NULL,
[driverIntId] [int] NULL,
[EventId] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessagingEventData] ADD CONSTRAINT [FK_MessagingEventData_CreationCode] FOREIGN KEY ([CreationCodeId]) REFERENCES [dbo].[CreationCode] ([CreationCodeId])
GO
ALTER TABLE [dbo].[MessagingEventData] ADD CONSTRAINT [FK_MessagingEventData_Customer] FOREIGN KEY ([CustomerIntId]) REFERENCES [dbo].[Customer] ([CustomerIntId])
GO
ALTER TABLE [dbo].[MessagingEventData] ADD CONSTRAINT [FK_MessagingEventData_Driver] FOREIGN KEY ([driverIntId]) REFERENCES [dbo].[Driver] ([DriverIntId])
GO
ALTER TABLE [dbo].[MessagingEventData] ADD CONSTRAINT [FK_MessagingEventData_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
