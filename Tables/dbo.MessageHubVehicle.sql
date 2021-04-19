CREATE TABLE [dbo].[MessageHubVehicle]
(
[MessageHubVehicleId] [uniqueidentifier] NOT NULL,
[ExternalRegistration] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VehicleId] [uniqueidentifier] NULL,
[LastOperation] [smalldatetime] NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_MessageHubVehicle_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageHubVehicle] ADD CONSTRAINT [PK_MessageHubVehicle] PRIMARY KEY CLUSTERED  ([MessageHubVehicleId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageHubVehicle] ADD CONSTRAINT [FK_MessageHubVehicle_Vehicle] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
