CREATE TABLE [dbo].[VehicleAnalogIoData]
(
[VehicleAnalogIoDataId] [bigint] NOT NULL,
[VehicleIntId] [int] NOT NULL,
[DriverIntId] [int] NULL,
[EventDateTime] [datetime] NOT NULL,
[Lat] [float] NULL,
[Long] [float] NULL,
[Speed] [tinyint] NULL,
[KeyOn] [bit] NULL,
[Value] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_VehicleAnalogIoData_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleAnalogIoData] ADD CONSTRAINT [PK_VehicleAnalogIoData] PRIMARY KEY CLUSTERED  ([VehicleAnalogIoDataId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleAnalogIoData] ADD CONSTRAINT [FK_VehicleAnalogIoData_Driver] FOREIGN KEY ([DriverIntId]) REFERENCES [dbo].[Driver] ([DriverIntId])
GO
ALTER TABLE [dbo].[VehicleAnalogIoData] ADD CONSTRAINT [FK_VehicleAnalogIoData_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
