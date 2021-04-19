CREATE TABLE [dbo].[VehicleDriver]
(
[VehicleId] [uniqueidentifier] NOT NULL,
[DriverId] [uniqueidentifier] NOT NULL,
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_VehicleDriver_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_VehicleDriver_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleDriver] ADD CONSTRAINT [FK_VehicleDriver_Driver] FOREIGN KEY ([DriverId]) REFERENCES [dbo].[Driver] ([DriverId])
GO
ALTER TABLE [dbo].[VehicleDriver] ADD CONSTRAINT [FK_VehicleDriver_Vehicle] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
