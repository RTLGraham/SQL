CREATE TABLE [dbo].[DIR_IncidentType]
(
[IncidentTypeId] [smallint] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DIR_IncidentType] ADD CONSTRAINT [PK_DIR_IncidentType] PRIMARY KEY CLUSTERED  ([IncidentTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
