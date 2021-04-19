CREATE TABLE [dbo].[Geofence]
(
[GeofenceId] [uniqueidentifier] NULL CONSTRAINT [DF_Geofence_GeofenceId] DEFAULT (newid()),
[GeofenceIntId] [int] NULL CONSTRAINT [DF__Geofence__Geofen__495B7911] DEFAULT (CONVERT([int],rand()*(1000000),(0))),
[GeofenceSpatialId] [bigint] NOT NULL IDENTITY(1, 1) NOT FOR REPLICATION,
[GeofenceTypeId] [int] NOT NULL,
[GeofenceCategoryId] [int] NOT NULL CONSTRAINT [DF_Geofence_GeofenceCategoryId] DEFAULT ((0)),
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Enabled] [bit] NULL CONSTRAINT [DF_Geofence_Enabled] DEFAULT ((0)),
[Archived] [bit] NULL CONSTRAINT [DF_Geofence_Archived] DEFAULT ((0)),
[LastModified] [datetime] NULL CONSTRAINT [DF_Geofence_LastModified] DEFAULT (getdate()),
[CreationDate] [datetime] NULL CONSTRAINT [DF_Geofence_CreationDate] DEFAULT (getdate()),
[CreationUserId] [uniqueidentifier] NULL,
[IsLocked] [bit] NULL,
[the_geom] [sys].[geometry] NULL,
[SiteId] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Radius1] [float] NULL,
[Radius2] [float] NULL,
[CenterLon] [float] NULL,
[CenterLat] [float] NULL,
[Recipients] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SpeedLimit] [tinyint] NULL,
[IsLookupExcluded] [bit] NULL CONSTRAINT [DF__Geofence__IsLook__4F145267] DEFAULT ((0)),
[IsTemperatureMonitored] [bit] NULL,
[IsVideoProhibited] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Geofence] ADD CONSTRAINT [PK_Geofence_1] PRIMARY KEY CLUSTERED  ([GeofenceSpatialId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_LatLon] ON [dbo].[Geofence] ([CenterLat], [CenterLon]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UserGeofence] ON [dbo].[Geofence] ([CreationUserId]) INCLUDE ([the_geom]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PrimaryKeyGeofenceId] ON [dbo].[Geofence] ([GeofenceId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Geofence] ADD CONSTRAINT [UQ__Geofence__FBE3F645792C75FC] UNIQUE NONCLUSTERED  ([GeofenceIntId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE SPATIAL INDEX [SIndx_Geofence_TheGeom] ON [dbo].[Geofence] ([the_geom]) USING geometry_grid  WITH (BOUNDING_BOX = (6, 41, 28, 54), GRIDS = (MEDIUM, MEDIUM, HIGH, HIGH), CELLS_PER_OBJECT = 64) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Geofence] ADD CONSTRAINT [FK_Geofence_GeofenceCategory] FOREIGN KEY ([GeofenceCategoryId]) REFERENCES [dbo].[GeofenceCategory] ([GeofenceCategoryId])
GO
ALTER TABLE [dbo].[Geofence] ADD CONSTRAINT [FK_Geofence_GeofenceType] FOREIGN KEY ([GeofenceTypeId]) REFERENCES [dbo].[GeofenceType] ([GeofenceTypeId])
GO
