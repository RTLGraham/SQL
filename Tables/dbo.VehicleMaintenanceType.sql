CREATE TABLE [dbo].[VehicleMaintenanceType]
(
[VehicleMaintenanceTypeID] [int] NOT NULL,
[Name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Archived] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleMaintenanceType] ADD CONSTRAINT [PK_VehicleMaintenanceType] PRIMARY KEY CLUSTERED  ([VehicleMaintenanceTypeID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VehicleMaintenanceType] ON [dbo].[VehicleMaintenanceType] ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
