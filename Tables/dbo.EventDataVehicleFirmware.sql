CREATE TABLE [dbo].[EventDataVehicleFirmware]
(
[EventDataId] [bigint] NOT NULL,
[EventDataName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDataString] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDataInt] [int] NULL,
[EventDataFloat] [float] NULL,
[EventDataBit] [bit] NULL,
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
