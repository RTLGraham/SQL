CREATE TABLE [dbo].[RevGeocodeSpeeding]
(
[RevGeocodeSpeedingId] [int] NOT NULL IDENTITY(1, 1),
[Long] [float] NOT NULL,
[Lat] [float] NOT NULL,
[StreetName] [nvarchar] (400) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_RevGeocodeSpeeding_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RevGeocodeSpeeding] ADD CONSTRAINT [PK_RevGeocodeSpeeding] PRIMARY KEY CLUSTERED  ([RevGeocodeSpeedingId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RevGeocodeSpeeding_LatLon] ON [dbo].[RevGeocodeSpeeding] ([Long], [Lat]) INCLUDE ([Archived]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
