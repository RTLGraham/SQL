CREATE TABLE [dbo].[NestleFuel]
(
[FleetNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Model] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Registration] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DepotName] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DepotNumber] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Sortenart] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ODOStart] [float] NULL,
[ODOEnd] [float] NULL,
[Distance] [float] NULL,
[Fuel] [float] NULL,
[NormConsumption] [float] NULL,
[Cost] [float] NULL,
[Consumption] [float] NULL,
[CostPer100km] [float] NULL,
[Deviation%] [float] NULL,
[Year] [int] NULL,
[Month] [int] NULL,
[Advice] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[F19] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
