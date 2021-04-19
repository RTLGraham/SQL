CREATE TABLE [dbo].[EventDataTemp]
(
[EventDataId] [bigint] NOT NULL IDENTITY(1, 1),
[EventDataName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDataString] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDataInt] [int] NULL,
[EventDataFloat] [float] NULL,
[EventDataBit] [bit] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_EventDataTemp_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NULL,
[EventDateTime] [datetime] NULL,
[CreationCodeId] [smallint] NULL,
[CustomerIntId] [int] NOT NULL CONSTRAINT [DF_EventDataTemp_CustomerIntId] DEFAULT ((0)),
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[EventId] [bigint] NULL
) ON [PRIMARY]
GO
