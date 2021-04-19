CREATE TABLE [dbo].[DiseaseOutbreakGeofenceType]
(
[DiseaseOutbreakGeofenceTypeId] [int] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_DiseaseOutbreakGeofenceType_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_DiseaseOutbreakGeofenceType_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DiseaseOutbreakGeofenceType] ADD CONSTRAINT [PK_DiseaseOutbreakGeofenceType] PRIMARY KEY CLUSTERED  ([DiseaseOutbreakGeofenceTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
