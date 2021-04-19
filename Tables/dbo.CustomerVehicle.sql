CREATE TABLE [dbo].[CustomerVehicle]
(
[VehicleId] [uniqueidentifier] NOT NULL,
[CustomerId] [uniqueidentifier] NOT NULL,
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CustomerVehicle_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_CustomerVehicle_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CustomerVehicle_VehicleId] ON [dbo].[CustomerVehicle] ([VehicleId], [StartDate], [EndDate]) INCLUDE ([Archived], [CustomerId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CustomerVehicle] ADD CONSTRAINT [FK_CustomerVehicle_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([CustomerId])
GO
ALTER TABLE [dbo].[CustomerVehicle] ADD CONSTRAINT [FK_CustomerVehicle_Vehicle] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
