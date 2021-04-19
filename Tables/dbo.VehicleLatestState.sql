CREATE TABLE [dbo].[VehicleLatestState]
(
[VehicleLatestStateId] [uniqueidentifier] NOT NULL CONSTRAINT [DF_VehicleLatestState_VehicleLatestStateId] DEFAULT (newsequentialid()),
[VehicleId] [uniqueidentifier] NOT NULL,
[StateTypeId] [smallint] NOT NULL,
[LastOperation] [smalldatetime] NOT NULL CONSTRAINT [DF_VehicleLatestState_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_VehicleLatestState_Archived] DEFAULT ((0)),
[CurrentDestination] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CurrentNotificationID] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleLatestState] ADD CONSTRAINT [PK_VehicleLatestState] PRIMARY KEY CLUSTERED  ([VehicleLatestStateId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleLatestState] ADD CONSTRAINT [FK_VehicleLatestState_Vehicle] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
