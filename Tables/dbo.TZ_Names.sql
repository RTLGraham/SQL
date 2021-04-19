CREATE TABLE [dbo].[TZ_Names]
(
[TimeZoneId] [smallint] NOT NULL,
[Language] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LocationName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DisplayName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DaylightName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StandardName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
