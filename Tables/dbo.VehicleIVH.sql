CREATE TABLE [dbo].[VehicleIVH]
(
[VehicleId] [uniqueidentifier] NOT NULL,
[IVHId] [uniqueidentifier] NOT NULL,
[StartDate] [datetime] NULL,
[EndDate] [datetime] NULL,
[LastOperation] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleIVH] ADD CONSTRAINT [FK_VehicleIVH_IVH] FOREIGN KEY ([IVHId]) REFERENCES [dbo].[IVH] ([IVHId])
GO
ALTER TABLE [dbo].[VehicleIVH] ADD CONSTRAINT [FK_VehicleIVH_Vehicle] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
