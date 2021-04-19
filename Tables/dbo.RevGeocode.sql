CREATE TABLE [dbo].[RevGeocode]
(
[RevGeocodeId] [int] NOT NULL IDENTITY(1, 1),
[Long] [float] NOT NULL,
[Lat] [float] NOT NULL,
[Address] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Postcode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF_RevGeocode_Archived] DEFAULT ((0)),
[LatLongIdx] [bigint] NULL,
[Confidence] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__RevGeocod__Confi__471D5F8D] DEFAULT ('M'),
[InsertDateTime] [datetime] NULL CONSTRAINT [DF__RevGeocod__Inser__481183C6] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RevGeocode] ADD CONSTRAINT [PK_RevGeocode] PRIMARY KEY CLUSTERED  ([RevGeocodeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RevGeocode_Confidence] ON [dbo].[RevGeocode] ([Confidence]) INCLUDE ([InsertDateTime]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RevGeocode] ON [dbo].[RevGeocode] ([LatLongIdx]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
