CREATE TABLE [dbo].[VehicleUnplannedPlay]
(
[VehicleUnplannedPlayId] [int] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NOT NULL,
[PlayStartDateTime] [datetime] NOT NULL,
[PlayEndDateTime] [datetime] NOT NULL,
[Reason] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserId] [uniqueidentifier] NOT NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_VehicleUnplannedPlay_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF__VehicleUn__Archi__7CB0348E] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleUnplannedPlay] ADD CONSTRAINT [PK_VehicleUnplannedPlay] PRIMARY KEY CLUSTERED  ([VehicleUnplannedPlayId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_VehicleUnplannedPlay_VehicleDates] ON [dbo].[VehicleUnplannedPlay] ([VehicleIntId], [PlayStartDateTime], [PlayEndDateTime]) INCLUDE ([VehicleUnplannedPlayId]) ON [PRIMARY]
GO
