CREATE TABLE [dbo].[TripsAndStopsState]
(
[TripsAndStopsStateID] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleID] [uniqueidentifier] NULL,
[KeyState] [bit] NULL,
[MovingState] [bit] NULL,
[LastKeyTime] [smalldatetime] NULL,
[LastMovingTime] [smalldatetime] NULL,
[LastKeyTotalDistance] [bigint] NULL,
[LastMovingTotalDistance] [bigint] NULL,
[PrevKeyID] [bigint] NULL,
[PrevMovingID] [bigint] NULL,
[Archived] [bit] NULL,
[LastPointTotalDistance] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripsAndStopsState] ADD CONSTRAINT [PK_TripsAndStopsState] PRIMARY KEY CLUSTERED  ([TripsAndStopsStateID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
