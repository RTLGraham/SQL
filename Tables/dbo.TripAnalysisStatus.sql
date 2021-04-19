CREATE TABLE [dbo].[TripAnalysisStatus]
(
[TripAnalysisStatusId] [smallint] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF__TripAnalysisStatus__Archi__78BFA819] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF__TripAnalysisStatus__LastO__79B3CC52] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripAnalysisStatus] ADD CONSTRAINT [PK_TripAnalysisStatus] PRIMARY KEY CLUSTERED  ([TripAnalysisStatusId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
