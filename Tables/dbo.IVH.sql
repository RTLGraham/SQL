CREATE TABLE [dbo].[IVH]
(
[IVHId] [uniqueidentifier] NOT NULL CONSTRAINT [DF_IVH_IVHId] DEFAULT (newsequentialid()),
[IVHIntId] [int] NOT NULL IDENTITY(1, 1),
[TrackerNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Manufacturer] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Model] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PacketType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SIMCardNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ServiceProvider] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SerialNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirmwareVersion] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AntennaType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_IVH_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_IVH_Archived] DEFAULT ((0)),
[IsTag] [bit] NULL,
[IVHTypeId] [int] NOT NULL CONSTRAINT [DF_IVH_IVHTypeId] DEFAULT ((0)),
[IsDev] [bit] NULL,
[FirmwareDate] [datetime] NULL,
[Firmware147Date] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IVH] ADD CONSTRAINT [PK_IVH] PRIMARY KEY CLUSTERED  ([IVHId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IVH] ADD CONSTRAINT [UQ__IVH__IVHIntId] UNIQUE NONCLUSTERED  ([IVHIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_IVH_Serial] ON [dbo].[IVH] ([SerialNumber]) INCLUDE ([IVHId], [IVHIntId], [TrackerNumber], [IVHTypeId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_IVH_TrackerNumber] ON [dbo].[IVH] ([TrackerNumber]) INCLUDE ([IVHId], [IVHIntId], [Archived], [IsTag]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IVH] ADD CONSTRAINT [FK_IVH_IVHType] FOREIGN KEY ([IVHTypeId]) REFERENCES [dbo].[IVHType] ([IVHTypeId])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Referred to as TrackerId in interface', 'SCHEMA', N'dbo', 'TABLE', N'IVH', 'COLUMN', N'TrackerNumber'
GO
