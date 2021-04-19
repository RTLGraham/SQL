CREATE TABLE [dbo].[EventSpeedingTransition]
(
[EventId] [bigint] NULL,
[StreetName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PostCode] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpeedLimit] [tinyint] NULL,
[Lat] [float] NULL,
[Lon] [float] NULL,
[FoundLat] [float] NULL,
[FoundLon] [float] NULL,
[ProcessInd] [tinyint] NULL,
[SpeedingDistance] [int] NULL,
[SpeedingHighDistance] [int] NULL,
[ChallengeInd] [smallint] NULL,
[PostedSpeedLimit] [tinyint] NULL,
[VehicleSpeedLimit] [tinyint] NULL,
[SpeedUnit] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpeedingDisputeTypeId] [int] NULL,
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[CustomerIntId] [int] NULL,
[EventDateTime] [datetime] NULL,
[Speed] [smallint] NULL,
[Heading] [smallint] NULL,
[CreationCodeId] [smallint] NULL
) ON [PRIMARY]
GO
