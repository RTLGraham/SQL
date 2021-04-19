CREATE TABLE [dbo].[VehicleLatestStatusTemp]
(
[VehicleIntId] [int] NOT NULL,
[UnitTime] [datetime] NULL,
[EcospeedStatus] [bit] NULL,
[SDCardStatus] [bit] NULL,
[Firmware] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LogNumber] [int] NULL,
[LastOperation] [datetime] NULL,
[Archived] [bit] NULL
) ON [PRIMARY]
GO
