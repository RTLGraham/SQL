CREATE TABLE [dbo].[CAM_CoachingOutcome]
(
[CoachingOutcomeId] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayOrder] [int] NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_CAM_CoachingOutcome_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_CAM_CoachingOutcome_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_CoachingOutcome] ADD CONSTRAINT [PK_CAM_CoachingOutcome] PRIMARY KEY CLUSTERED  ([CoachingOutcomeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
