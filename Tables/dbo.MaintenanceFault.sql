CREATE TABLE [dbo].[MaintenanceFault]
(
[MaintenanceFaultId] [int] NOT NULL IDENTITY(1, 1),
[MaintenanceJobId] [int] NOT NULL,
[FaultTypeId] [smallint] NOT NULL,
[FaultDateTime] [datetime] NOT NULL,
[AssetTypeId] [smallint] NULL,
[AssetReference] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AcknowledgedBy] [uniqueidentifier] NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_MaintenanceFault_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_MaintenanceFault_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MaintenanceFault] ADD CONSTRAINT [PK_MaintenanceFault] PRIMARY KEY CLUSTERED  ([MaintenanceFaultId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MaintenanceFault] WITH NOCHECK ADD CONSTRAINT [FK_MaintenanceFault_Asset] FOREIGN KEY ([AssetTypeId]) REFERENCES [dbo].[MaintenanceAssetType] ([AssetTypeId])
GO
ALTER TABLE [dbo].[MaintenanceFault] WITH NOCHECK ADD CONSTRAINT [FK_MaintenanceFault_Fault] FOREIGN KEY ([FaultTypeId]) REFERENCES [dbo].[MaintenanceFaultType] ([FaultTypeId])
GO
ALTER TABLE [dbo].[MaintenanceFault] WITH NOCHECK ADD CONSTRAINT [FK_MaintenanceFault_Job] FOREIGN KEY ([MaintenanceJobId]) REFERENCES [dbo].[MaintenanceJob] ([MaintenanceJobId])
GO
