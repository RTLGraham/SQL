CREATE TABLE [dbo].[SCAM_DataIn]
(
[IMEI] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EventId] [bigint] NOT NULL,
[CustomerIntId] [int] NULL,
[VehicleIntId] [int] NULL,
[CamIntId] [int] NULL,
[DriverIntId] [int] NULL,
[CreationCodeId] [smallint] NULL,
[EventDateTime] [datetime] NULL,
[Long] [float] NULL,
[Lat] [float] NULL,
[Heading] [smallint] NULL,
[Speed] [smallint] NULL,
[Altitude] [float] NULL,
[OdoGPS] [int] NULL,
[GPSSatelliteCount] [tinyint] NULL,
[GPRSSignalStrength] [tinyint] NULL,
[SeqNumber] [int] NULL,
[IgnitionStatus] [tinyint] NULL,
[EventDataName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDataString] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcessInd] [tinyint] NULL,
[LastOperation] [smalldatetime] NULL
) ON [PRIMARY]
GO
