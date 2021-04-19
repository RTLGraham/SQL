CREATE TABLE [dbo].[DiseaseOutbreakGeofence]
(
[DiseaseOutbreakGeofenceId] [int] NOT NULL IDENTITY(1, 1),
[DiseaseOutbreakId] [int] NOT NULL,
[GeofenceId] [uniqueidentifier] NULL,
[DiseaseOutbreakGeofenceTypeId] [int] NOT NULL,
[AnnotationText] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_DiseaseOutbreakGeofence_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_DiseaseOutbreakGeofence_LastOperation] DEFAULT (getdate()),
[IsVisible] [bit] NOT NULL CONSTRAINT [DF_DiseaseOutbreakGeofence_IsVisible] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DiseaseOutbreakGeofence] ADD CONSTRAINT [PK_DiseaseOutbreakGeofence] PRIMARY KEY CLUSTERED  ([DiseaseOutbreakGeofenceId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DiseaseOutbreakGeofence] WITH NOCHECK ADD CONSTRAINT [FK_DiseaseOutbreak_Id] FOREIGN KEY ([DiseaseOutbreakId]) REFERENCES [dbo].[DiseaseOutbreak] ([DiseaseOutbreakId])
GO
ALTER TABLE [dbo].[DiseaseOutbreakGeofence] WITH NOCHECK ADD CONSTRAINT [FK_DiseaseOutbreak_Type] FOREIGN KEY ([DiseaseOutbreakGeofenceTypeId]) REFERENCES [dbo].[DiseaseOutbreakGeofenceType] ([DiseaseOutbreakGeofenceTypeId])
GO
