CREATE TABLE [dbo].[CAM_CoachingSession]
(
[CoachingSessionId] [int] NOT NULL IDENTITY(1, 1),
[CoachingStatusId] [int] NOT NULL CONSTRAINT [DF_CAM_Coaching_CoachingStatusId] DEFAULT ((1)),
[CoachUserId] [uniqueidentifier] NOT NULL,
[CoachedDriverId] [uniqueidentifier] NOT NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_CAM_Coaching_Archived] DEFAULT ((0)),
[LastOperation] [datetime] NOT NULL CONSTRAINT [DF_CAM_Coaching_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_CoachingSession] ADD CONSTRAINT [PK_CAM_CoachingSession] PRIMARY KEY CLUSTERED  ([CoachingSessionId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
