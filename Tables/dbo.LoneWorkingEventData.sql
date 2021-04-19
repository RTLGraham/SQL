CREATE TABLE [dbo].[LoneWorkingEventData]
(
[EventDataId] [uniqueidentifier] NOT NULL,
[EventDataName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDataString] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDataInt] [int] NULL,
[EventDataFloat] [float] NULL,
[EventDataBit] [bit] NULL,
[Lat] [float] NULL,
[Long] [float] NULL,
[LastOperation] [smalldatetime] NULL,
[Archived] [bit] NULL,
[EventDateTime] [datetime] NULL,
[CreationCodeId] [smallint] NULL,
[CustomerIntId] [int] NULL,
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[EventId] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LoneWorkingEventData] ADD CONSTRAINT [FK_LoneWorkingEventData_CreationCode] FOREIGN KEY ([CreationCodeId]) REFERENCES [dbo].[CreationCode] ([CreationCodeId])
GO
ALTER TABLE [dbo].[LoneWorkingEventData] ADD CONSTRAINT [FK_LoneWorkingEventData_Customer] FOREIGN KEY ([CustomerIntId]) REFERENCES [dbo].[Customer] ([CustomerIntId])
GO
ALTER TABLE [dbo].[LoneWorkingEventData] ADD CONSTRAINT [FK_LoneWorkingEventData_Driver] FOREIGN KEY ([DriverIntId]) REFERENCES [dbo].[Driver] ([DriverIntId])
GO
ALTER TABLE [dbo].[LoneWorkingEventData] ADD CONSTRAINT [FK_LoneWorkingEventData_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
