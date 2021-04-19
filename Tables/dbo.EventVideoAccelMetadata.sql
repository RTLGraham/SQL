CREATE TABLE [dbo].[EventVideoAccelMetadata]
(
[EventVideoAccelMetadataId] [bigint] NOT NULL,
[EventVideoId] [bigint] NULL,
[MetadataDateTime] [datetime] NOT NULL,
[x] [float] NOT NULL,
[y] [float] NOT NULL,
[z] [float] NOT NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_EventVideoAccelMetadata_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EventVideoAccelMetadata] ADD CONSTRAINT [PK_EventVideoAccelMetadata] PRIMARY KEY CLUSTERED  ([EventVideoAccelMetadataId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
