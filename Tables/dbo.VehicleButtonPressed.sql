CREATE TABLE [dbo].[VehicleButtonPressed]
(
[VehicleIntId] [int] NOT NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_VehicleButtonPressed_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleButtonPressed] ADD CONSTRAINT [PK_VehicleButtonPressed] PRIMARY KEY CLUSTERED  ([VehicleIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
