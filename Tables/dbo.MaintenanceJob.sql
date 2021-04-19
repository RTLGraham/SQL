CREATE TABLE [dbo].[MaintenanceJob]
(
[MaintenanceJobId] [int] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NULL,
[IVHIntId] [int] NULL,
[CreationDateTime] [datetime] NULL,
[EngineerDateTime] [datetime] NULL,
[Engineer] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SupportTicketId] [int] NULL,
[ResolvedDateTime] [datetime] NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_MaintenanceJob_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_MaintenanceJob_LastOperation] DEFAULT (getdate()),
[AssignedGroupId] [uniqueidentifier] NULL,
[AssignedUserId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MaintenanceJob] ADD CONSTRAINT [PK_MaintenanceJob] PRIMARY KEY CLUSTERED  ([MaintenanceJobId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MaintenanceJob] WITH NOCHECK ADD CONSTRAINT [FK_MaintenanceJob_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
