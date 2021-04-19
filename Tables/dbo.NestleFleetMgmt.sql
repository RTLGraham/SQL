CREATE TABLE [dbo].[NestleFleetMgmt]
(
[FleetNum] [float] NULL,
[Model] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Registration] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DepotName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DepotNumber] [float] NULL,
[Exclude] [float] NULL,
[v80Year] [float] NULL,
[v80Month] [float] NULL,
[v80Day] [float] NULL,
[HasTotF] [float] NULL,
[HasTotD] [float] NULL,
[Has1364Msg] [float] NULL,
[SprinterNoCan] [float] NULL,
[SprinterCAN] [float] NULL,
[Atego4Cyl] [float] NULL,
[Atego6Cyl] [float] NULL,
[AtegoUnkown] [float] NULL,
[Comments] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
