CREATE TABLE [dbo].[VehicleMode]
(
[VehicleModeID] [int] NOT NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleMode] ADD CONSTRAINT [PK_VehicleMode] PRIMARY KEY CLUSTERED  ([VehicleModeID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_VehicleModeName] ON [dbo].[VehicleMode] ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
