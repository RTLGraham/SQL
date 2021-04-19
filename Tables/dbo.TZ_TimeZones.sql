CREATE TABLE [dbo].[TZ_TimeZones]
(
[TimeZoneId] [smallint] NOT NULL,
[TimeZoneName] [nchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[UtcOffset] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TZ_TimeZones] ADD CONSTRAINT [PK_TZ_TimeZones] PRIMARY KEY CLUSTERED  ([TimeZoneId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
