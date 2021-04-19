CREATE TABLE [dbo].[VehicleSWUpdates]
(
[VehicleId] [uniqueidentifier] NOT NULL,
[UnitType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SoftwareVersionPending] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CalPrefixPending] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CalSuffixPending] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SoftwareVersionCurrent] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpdatePending] [bit] NOT NULL CONSTRAINT [DF_VehiclesSWUpdates_UpdatePending] DEFAULT ('0'),
[UpdateCommandId] [int] NULL,
[LastOperationUpdatePending] [datetime] NOT NULL CONSTRAINT [DF_VehiclesSWUpdates_LastOperationUpdatePending] DEFAULT (getdate()),
[UpdateComplete] [bit] NOT NULL CONSTRAINT [DF_VehiclesSWUpdates_UpdateComplete] DEFAULT ('0'),
[LastOperationUpdateComplete] [datetime] NOT NULL CONSTRAINT [DF_VehiclesSWUpdates_LastOperationUpdateComplete] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_VehiclesSWUpdates_Archived] DEFAULT ((0)),
[Notes] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SentCGPRS] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleSWUpdates] ADD CONSTRAINT [PK_VehicleSWUpdates] PRIMARY KEY CLUSTERED  ([VehicleId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
