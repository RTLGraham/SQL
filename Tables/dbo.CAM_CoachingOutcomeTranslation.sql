CREATE TABLE [dbo].[CAM_CoachingOutcomeTranslation]
(
[CoachingOutcomeTranslationId] [int] NOT NULL IDENTITY(1, 1),
[CoachingOutcomeId] [int] NOT NULL,
[LanguageCulture] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayDescription] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_CAM_CoachingOutcomeTranslation_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_CAM_CoachingOutcomeTranslation_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_CoachingOutcomeTranslation] ADD CONSTRAINT [PK_CAM_CoachingOutcomeTranslation] PRIMARY KEY CLUSTERED  ([CoachingOutcomeTranslationId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_CoachingOutcomeTranslation] ADD CONSTRAINT [FK_CAM_CoachingOutcomeTranslation_CAM_CoachingOutcome] FOREIGN KEY ([CoachingOutcomeId]) REFERENCES [dbo].[CAM_CoachingOutcome] ([CoachingOutcomeId])
GO
