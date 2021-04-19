CREATE TABLE [dbo].[TescoIncidentType]
(
[IncidentTypeID] [int] NOT NULL,
[Name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL CONSTRAINT [DF__TescoReco__Archi__0F8DFED8] DEFAULT ((0)),
[RecordTypeId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TescoIncidentType] ADD CONSTRAINT [PK_TescoRecordType] PRIMARY KEY CLUSTERED  ([IncidentTypeID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
