CREATE TABLE [dbo].[CFG_DSW_Vehicle]
(
[CFGId] [int] NOT NULL IDENTITY(1, 1),
[VehicleId] [uniqueidentifier] NOT NULL,
[ProcessInd] [tinyint] NOT NULL CONSTRAINT [DF_CFG_DSW_Vehicle_ProcessInd] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CFG_DSW_Vehicle_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CFG_DSW_Vehicle] ADD CONSTRAINT [PK_CFG_DSW_Vehicle] PRIMARY KEY CLUSTERED  ([CFGId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CFG_DSW_vehicle_ProcessInd] ON [dbo].[CFG_DSW_Vehicle] ([ProcessInd]) INCLUDE ([VehicleId]) ON [PRIMARY]
GO
