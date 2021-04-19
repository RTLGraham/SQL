CREATE TABLE [dbo].[VehicleGeofence]
(
[VehicleIntId] [int] NOT NULL,
[GeofenceId] [uniqueidentifier] NULL,
[EventDateTime] [datetime] NOT NULL,
[LastOperation] [smalldatetime] NOT NULL CONSTRAINT [DF_VehicleGeofence_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_VehicleGeofence_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleGeofence] ADD CONSTRAINT [PK_VehicleGeofence] PRIMARY KEY CLUSTERED  ([VehicleIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
