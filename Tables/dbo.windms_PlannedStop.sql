CREATE TABLE [dbo].[windms_PlannedStop]
(
[StopId] [numeric] (8, 0) NOT NULL IDENTITY(1, 1),
[GeoID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lat] [bigint] NULL,
[Lon] [bigint] NULL,
[Address] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Radious] [smallint] NULL,
[EstStartTime] [datetime] NULL,
[EstEndTime] [datetime] NULL,
[JobId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF__windms_Pl__Archi__7015537F] DEFAULT ((0))
) ON [PRIMARY]
GO
