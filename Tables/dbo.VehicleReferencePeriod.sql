CREATE TABLE [dbo].[VehicleReferencePeriod]
(
[ReferencePeriodId] [int] NOT NULL IDENTITY(1, 1),
[VehicleId] [uniqueidentifier] NOT NULL,
[InstallDate] [datetime] NULL,
[StartDate] [datetime] NOT NULL,
[EndDate] [datetime] NOT NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF__VehicleRe__Archi__00AAE2A4] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleReferencePeriod] ADD CONSTRAINT [PK_VehicleReferencePeriod] PRIMARY KEY CLUSTERED  ([ReferencePeriodId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleReferencePeriod] WITH NOCHECK ADD CONSTRAINT [FK_VehicleReferencePeriod_VehicleId] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
