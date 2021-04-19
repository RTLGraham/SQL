CREATE TABLE [dbo].[VehicleAnalogIoDataTemp]
(
[VehicleAnalogIoDataId] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NOT NULL,
[DriverIntId] [int] NULL,
[EventDateTime] [datetime] NOT NULL,
[Lat] [float] NULL,
[Long] [float] NULL,
[Speed] [tinyint] NULL,
[KeyOn] [bit] NULL,
[Value] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_VehicleAnalogIoDataTemp_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
