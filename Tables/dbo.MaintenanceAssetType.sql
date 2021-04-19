CREATE TABLE [dbo].[MaintenanceAssetType]
(
[AssetTypeId] [smallint] NOT NULL,
[Name] [nvarchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_MaintenanceAssetType_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_MaintenanceAssetType_Archived] DEFAULT ((0)),
[Severity] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MaintenanceAssetType] ADD CONSTRAINT [PK_MaintenanceAssetType] PRIMARY KEY CLUSTERED  ([AssetTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MaintenanceAssetType] ADD CONSTRAINT [UN_Name_MaintenanceAssetType] UNIQUE NONCLUSTERED  ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
