CREATE TABLE [dbo].[TripsAndStopsWorkPlay]
(
[TripsAndStopsId] [bigint] NOT NULL,
[PlayInd] [bit] NULL,
[Comment] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripsAndStopsWorkPlay] ADD CONSTRAINT [PK_TripsAndStopsWorkPlay] PRIMARY KEY CLUSTERED  ([TripsAndStopsId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
