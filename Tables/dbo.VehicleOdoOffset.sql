CREATE TABLE [dbo].[VehicleOdoOffset]
(
[VehicleIntId] [int] NOT NULL,
[OdometerOffset] [int] NOT NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_VehicleOdoOffset_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleOdoOffset] ADD CONSTRAINT [PK_VehicleOdoOffset] PRIMARY KEY CLUSTERED  ([VehicleIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
