CREATE TABLE [dbo].[EventVideoAccelMetadataTemp]
(
[EventVideoAccelMetadataId] [bigint] NOT NULL IDENTITY(1, 1),
[EventVideoId] [bigint] NULL,
[MetadataDateTime] [datetime] NOT NULL,
[x] [float] NOT NULL,
[y] [float] NOT NULL,
[z] [float] NOT NULL,
[Archived] [bit] NULL
) ON [PRIMARY]
GO
