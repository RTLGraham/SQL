CREATE TABLE [dbo].[DIR_IncidentDetail]
(
[IncidentDetailId] [int] NOT NULL IDENTITY(1, 1),
[IncidentID] [int] NULL,
[IncidentFieldID] [int] NULL,
[Contents] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DIR_IncidentDetail] ADD CONSTRAINT [PK_DIR_IncidentDetail] PRIMARY KEY CLUSTERED  ([IncidentDetailId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DIR_IncidentDetail] ADD CONSTRAINT [FK_DIR_Incident_IncidentField2] FOREIGN KEY ([IncidentFieldID]) REFERENCES [dbo].[DIR_IncidentField] ([IncidentFieldID])
GO
ALTER TABLE [dbo].[DIR_IncidentDetail] ADD CONSTRAINT [FK_DIR_Incident_IncidentID] FOREIGN KEY ([IncidentID]) REFERENCES [dbo].[DIR_Incident] ([IncidentId])
GO
