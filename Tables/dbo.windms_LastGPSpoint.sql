CREATE TABLE [dbo].[windms_LastGPSpoint]
(
[VehicleId] [uniqueidentifier] NOT NULL,
[LastOperation] [smalldatetime] NULL,
[TruckId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[windms_LastGPSpoint] ADD CONSTRAINT [PK__windms_LastGPSpo__74DA089C] PRIMARY KEY CLUSTERED  ([VehicleId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
