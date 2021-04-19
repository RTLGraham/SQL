CREATE TABLE [dbo].[CAM_CoachingResult]
(
[CoachingResultId] [int] NOT NULL IDENTITY(1, 1),
[CoachingSessionId] [int] NOT NULL,
[CoachingOutcomeId] [int] NOT NULL,
[CoachingOutcomeComment] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_CAM_CoachingResult_Archived] DEFAULT ((0)),
[LastOperation] [datetime] NOT NULL CONSTRAINT [DF_CAM_CoachingResult_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_CoachingResult] ADD CONSTRAINT [PK_CAM_CoachingResult] PRIMARY KEY CLUSTERED  ([CoachingResultId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_CoachingResult] ADD CONSTRAINT [FK_CAM_CoachingResult_CAM_CoachingOutcome] FOREIGN KEY ([CoachingOutcomeId]) REFERENCES [dbo].[CAM_CoachingOutcome] ([CoachingOutcomeId])
GO
ALTER TABLE [dbo].[CAM_CoachingResult] ADD CONSTRAINT [FK_CAM_CoachingResult_CAM_CoachingSession] FOREIGN KEY ([CoachingSessionId]) REFERENCES [dbo].[CAM_CoachingSession] ([CoachingSessionId])
GO
