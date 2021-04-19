CREATE TABLE [dbo].[VehicleModeCreationCode]
(
[CreationCodeId] [smallint] NOT NULL,
[VehicleModeId] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleModeCreationCode] ADD CONSTRAINT [PK_VehicleModeCreationCodes] PRIMARY KEY CLUSTERED  ([CreationCodeId], [VehicleModeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
