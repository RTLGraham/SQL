CREATE TABLE [dbo].[UnitInfo]
(
[UnitInfoId] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleId] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastComs] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JobsRead] [int] NULL,
[UnitTime] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EconoSpeed] [bit] NULL,
[SDcard] [bit] NULL,
[Firmware] [nchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UpgradeLevel] [int] NULL,
[UpgradeID] [int] NULL,
[UpgradePos] [int] NULL,
[UpgradeFile] [int] NULL,
[UpgradeSectors] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UnitInfo] ADD CONSTRAINT [PK_UnitInfo] PRIMARY KEY CLUSTERED  ([UnitInfoId]) ON [PRIMARY]
GO
