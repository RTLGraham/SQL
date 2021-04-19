CREATE TABLE [dbo].[MaintenanceExclusion]
(
[MaintenanceExclusionId] [int] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NOT NULL,
[FaultTypeId] [smallint] NOT NULL,
[ExcludeUntil] [datetime] NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_MaintenanceExclusion_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_MaintenanceExclusion_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MaintenanceExclusion] ADD CONSTRAINT [PK_MaintenanceExclusion] PRIMARY KEY CLUSTERED  ([MaintenanceExclusionId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MaintenanceExclusion] WITH NOCHECK ADD CONSTRAINT [FK_MaintenanceExclusion_Fault] FOREIGN KEY ([FaultTypeId]) REFERENCES [dbo].[MaintenanceFaultType] ([FaultTypeId])
GO
ALTER TABLE [dbo].[MaintenanceExclusion] WITH NOCHECK ADD CONSTRAINT [FK_MaintenanceExclusion_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
