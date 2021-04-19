CREATE TABLE [dbo].[TripsAndStopsConfig]
(
[TripsAndStopsConfigID] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleID] [uniqueidentifier] NULL,
[MinGap] [int] NULL,
[ExpiryDay] [int] NULL,
[Archived] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripsAndStopsConfig] ADD CONSTRAINT [PK_IVHConfig] PRIMARY KEY CLUSTERED  ([TripsAndStopsConfigID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
