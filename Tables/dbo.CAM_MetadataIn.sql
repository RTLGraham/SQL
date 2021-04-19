CREATE TABLE [dbo].[CAM_MetadataIn]
(
[MetadataInId] [bigint] NOT NULL IDENTITY(1, 1),
[CreationCodeId] [smallint] NULL,
[ApiEventId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiMetadataId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CAM_MetadataIn_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_CAM_MetadataIn_Archived] DEFAULT ((0)),
[MinX] [float] NULL,
[MaxX] [float] NULL,
[MinY] [float] NULL,
[MaxY] [float] NULL,
[MinZ] [float] NULL,
[MaxZ] [float] NULL,
[ProjectId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_MetadataIn] ADD CONSTRAINT [PK_CAM_MetadataIn] PRIMARY KEY CLUSTERED  ([MetadataInId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAM_MetadataIn_ApiEventId] ON [dbo].[CAM_MetadataIn] ([ApiEventId], [Archived]) INCLUDE ([ApiMetadataId], [CreationCodeId], [MetadataInId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAM_MetadataIn_Archived] ON [dbo].[CAM_MetadataIn] ([Archived]) INCLUDE ([MetadataInId], [CreationCodeId], [ApiEventId], [ApiMetadataId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAM_MetadataIn_LastOperation] ON [dbo].[CAM_MetadataIn] ([LastOperation]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAMMetadataIn_Project] ON [dbo].[CAM_MetadataIn] ([ProjectId], [Archived]) ON [PRIMARY]
GO
