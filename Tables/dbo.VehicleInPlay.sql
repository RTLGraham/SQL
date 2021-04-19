CREATE TABLE [dbo].[VehicleInPlay]
(
[VehicleIntId] [int] NOT NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_VehicleInPlay_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleInPlay] ADD CONSTRAINT [PK_VehicleInPlay] PRIMARY KEY CLUSTERED  ([VehicleIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
