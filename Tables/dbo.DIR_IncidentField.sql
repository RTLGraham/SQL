CREATE TABLE [dbo].[DIR_IncidentField]
(
[IncidentFieldID] [int] NOT NULL,
[Name] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FieldType] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DIR_IncidentField] ADD CONSTRAINT [PK_DIR_IncidentField] PRIMARY KEY CLUSTERED  ([IncidentFieldID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
