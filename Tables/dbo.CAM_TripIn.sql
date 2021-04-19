CREATE TABLE [dbo].[CAM_TripIn]
(
[TripInId] [bigint] NOT NULL IDENTITY(1, 1),
[ProjectId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VehicleId] [uniqueidentifier] NULL,
[TripStart] [datetime] NULL,
[TripStop] [datetime] NULL,
[TripDistance] [int] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CAM_TripIn_LastOperation] DEFAULT (getdate()),
[ProcessInd] [tinyint] NULL,
[TripState] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TripStartLat] [float] NULL,
[TripStartLon] [float] NULL,
[TripEndLat] [float] NULL,
[TripEndLon] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_TripIn] ADD CONSTRAINT [PK_CAM_TripIn] PRIMARY KEY CLUSTERED  ([TripInId]) WITH (IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAMTripIn_Project] ON [dbo].[CAM_TripIn] ([ProjectId], [ProcessInd]) ON [PRIMARY]
GO
