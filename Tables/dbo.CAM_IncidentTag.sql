CREATE TABLE [dbo].[CAM_IncidentTag]
(
[IncidentTagId] [int] NOT NULL IDENTITY(1, 1),
[IncidentId] [bigint] NOT NULL,
[TagId] [int] NOT NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_CAM_IncidentTag_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_CAM_IncidentTag_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_IncidentTag] ADD CONSTRAINT [PK_CAM_IncidentTag] PRIMARY KEY CLUSTERED  ([IncidentTagId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAM_IncidentTag_Incident] ON [dbo].[CAM_IncidentTag] ([IncidentId], [Archived]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_IncidentTag] ADD CONSTRAINT [FK_CAM_IncidentTag_CAM_Incident] FOREIGN KEY ([IncidentId]) REFERENCES [dbo].[CAM_Incident] ([IncidentId])
GO
ALTER TABLE [dbo].[CAM_IncidentTag] ADD CONSTRAINT [FK_CAM_IncidentTag_CAM_Tag] FOREIGN KEY ([TagId]) REFERENCES [dbo].[CAM_Tag] ([TagId])
GO
