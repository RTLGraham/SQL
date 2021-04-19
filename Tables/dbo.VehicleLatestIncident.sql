CREATE TABLE [dbo].[VehicleLatestIncident]
(
[VehicleLatestIncidentId] [uniqueidentifier] NOT NULL CONSTRAINT [DF_VehicleLatestIncident_VehicleLatestIncidentId] DEFAULT (newsequentialid()),
[VehicleId] [uniqueidentifier] NOT NULL,
[CameraId] [uniqueidentifier] NOT NULL,
[IncidentId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastOperation] [smalldatetime] NOT NULL CONSTRAINT [DF_VehicleLatestIncident_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_VehicleLatestIncident_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleLatestIncident] ADD CONSTRAINT [PK_VehicleLatestIncident] PRIMARY KEY CLUSTERED  ([VehicleLatestIncidentId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleLatestIncident] ADD CONSTRAINT [FK_VehicleLatestIncident_Camera] FOREIGN KEY ([CameraId]) REFERENCES [dbo].[Camera] ([CameraId])
GO
ALTER TABLE [dbo].[VehicleLatestIncident] ADD CONSTRAINT [FK_VehicleLatestIncident_Vehicle] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
