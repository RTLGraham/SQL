CREATE TABLE [dbo].[DIR_Incident]
(
[IncidentId] [int] NOT NULL IDENTITY(1, 1),
[DriverIntId] [int] NULL,
[IncidentDate] [datetime] NULL,
[IncidentTypeId] [smallint] NULL,
[Archived] [bit] NULL CONSTRAINT [DF_DIR_Incident_Archived] DEFAULT ((0)),
[LastOperation] [datetime] NULL CONSTRAINT [DF_DIR_Incident_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DIR_Incident] ADD CONSTRAINT [PK_DIR_Incident] PRIMARY KEY CLUSTERED  ([IncidentId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DIR_Incident] ADD CONSTRAINT [FK_DIR_Incident_Driver] FOREIGN KEY ([DriverIntId]) REFERENCES [dbo].[Driver] ([DriverIntId])
GO
ALTER TABLE [dbo].[DIR_Incident] ADD CONSTRAINT [FK_DIR_Incident_IncidentType] FOREIGN KEY ([IncidentTypeId]) REFERENCES [dbo].[DIR_IncidentType] ([IncidentTypeId])
GO
