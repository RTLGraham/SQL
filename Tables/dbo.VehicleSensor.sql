CREATE TABLE [dbo].[VehicleSensor]
(
[VehicleSensorId] [int] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NOT NULL,
[SensorId] [smallint] NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShortName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Colour] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Enabled] [bit] NOT NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_VehicleSensor_LastOperation] DEFAULT (getdate()),
[DigitalSensorTypeId] [smallint] NULL,
[AnalogSensorScaleFactor] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleSensor] ADD CONSTRAINT [PK_VehicleSensor] PRIMARY KEY CLUSTERED  ([VehicleSensorId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VehicleSensor_Vehicle] ON [dbo].[VehicleSensor] ([VehicleIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleSensor] ADD CONSTRAINT [FK_VehicleSensor_DigitalSensorTypeId] FOREIGN KEY ([DigitalSensorTypeId]) REFERENCES [dbo].[DigitalSensorType] ([DigitalSensorTypeId])
GO
ALTER TABLE [dbo].[VehicleSensor] ADD CONSTRAINT [FK_VehicleSensor_Sensor] FOREIGN KEY ([SensorId]) REFERENCES [dbo].[Sensor] ([SensorId])
GO
ALTER TABLE [dbo].[VehicleSensor] ADD CONSTRAINT [FK_VehicleSensor_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
