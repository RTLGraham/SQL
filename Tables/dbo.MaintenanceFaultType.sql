CREATE TABLE [dbo].[MaintenanceFaultType]
(
[FaultTypeId] [smallint] NOT NULL,
[Name] [nvarchar] (254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_MaintenanceFaultType_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_MaintenanceFaultType_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MaintenanceFaultType] ADD CONSTRAINT [PK_MaintenanceFaultType] PRIMARY KEY CLUSTERED  ([FaultTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MaintenanceFaultType] ADD CONSTRAINT [UN_Name_MaintenanceFaultType] UNIQUE NONCLUSTERED  ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
