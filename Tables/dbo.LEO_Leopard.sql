CREATE TABLE [dbo].[LEO_Leopard]
(
[LeopardId] [int] NOT NULL IDENTITY(1, 1),
[IVHId] [uniqueidentifier] NULL,
[DeviceTypeId] [int] NULL,
[SystemInfoDate] [datetime] NULL,
[LastOperation] [smalldatetime] NOT NULL CONSTRAINT [DF__LEO_Leopa__LastO__53991062] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF__LEO_Leopa__Archi__548D349B] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_Leopard] ADD CONSTRAINT [PK_LEO_Leopard] PRIMARY KEY CLUSTERED  ([LeopardId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_Leopard] ADD CONSTRAINT [FK_LEO_DeviceType] FOREIGN KEY ([DeviceTypeId]) REFERENCES [dbo].[LEO_DeviceType] ([DeviceTypeId])
GO
ALTER TABLE [dbo].[LEO_Leopard] ADD CONSTRAINT [FK_LEO_IVH] FOREIGN KEY ([IVHId]) REFERENCES [dbo].[IVH] ([IVHId])
GO
