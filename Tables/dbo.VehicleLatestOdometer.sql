CREATE TABLE [dbo].[VehicleLatestOdometer]
(
[VehicleLatestOdometerId] [int] NOT NULL IDENTITY(1, 1),
[VehicleId] [uniqueidentifier] NOT NULL,
[OdoGPS] [int] NOT NULL,
[EventDateTime] [datetime] NOT NULL,
[LastOperation] [smalldatetime] NOT NULL CONSTRAINT [DF_VehicleLatestOdometer_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_VehicleLatestOdometer_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleLatestOdometer] ADD CONSTRAINT [PK_VehicleLatestOdometer] PRIMARY KEY CLUSTERED  ([VehicleLatestOdometerId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VehicleLatestOdometer_Vehicle] ON [dbo].[VehicleLatestOdometer] ([VehicleId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleLatestOdometer] ADD CONSTRAINT [FK_VehicleLatestOdometer_Vehicle] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
