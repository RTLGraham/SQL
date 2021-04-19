CREATE TABLE [dbo].[Rubicon_TrucksVehicles]
(
[TrucksVehiclesId] [int] NOT NULL IDENTITY(1, 1),
[VehicleId] [uniqueidentifier] NULL,
[TruckId] [bigint] NULL,
[IVHId] [uniqueidentifier] NULL,
[StartDate] [datetime] NULL CONSTRAINT [DF__Rubicon_Tr__Start__71FD9BF1] DEFAULT (getdate()),
[EndDate] [datetime] NULL,
[LastOperation] [smalldatetime] NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF__Rubicon_Tr__Archi__72F1C02A] DEFAULT ((0))
) ON [PRIMARY]
GO
