CREATE TABLE [dbo].[WKD_WorkDiaryTransition]
(
[WorkDiaryTransitionId] [bigint] NOT NULL IDENTITY(1, 1),
[WorkDiaryPageId] [int] NOT NULL,
[VehicleIntId] [int] NULL,
[WorkStateTypeId] [int] NULL,
[TransitionDateTime] [smalldatetime] NOT NULL,
[Odometer] [int] NULL,
[Lat] [float] NULL,
[Long] [float] NULL,
[Location] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TwoUpInd] [bit] NULL,
[Note] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_WKD_WorkDiaryTransition_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_WKD_WorkDiaryTransition_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WKD_WorkDiaryTransition] ADD CONSTRAINT [PK_WKD_WorkDiaryTransition] PRIMARY KEY CLUSTERED  ([WorkDiaryTransitionId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_WorkDiaryTransition_Page] ON [dbo].[WKD_WorkDiaryTransition] ([WorkDiaryPageId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WKD_WorkDiaryTransition] ADD CONSTRAINT [FK_WKD_WorkDiaryTransition_State] FOREIGN KEY ([WorkStateTypeId]) REFERENCES [dbo].[WKD_WorkStateType] ([WorkStateTypeId])
GO
ALTER TABLE [dbo].[WKD_WorkDiaryTransition] ADD CONSTRAINT [FK_WKD_WorkDiaryTransition_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
ALTER TABLE [dbo].[WKD_WorkDiaryTransition] ADD CONSTRAINT [FK_WKD_WorkDiaryTransition_WorkDiaryPage] FOREIGN KEY ([WorkDiaryPageId]) REFERENCES [dbo].[WKD_WorkDiaryPage] ([WorkDiaryPageId])
GO
