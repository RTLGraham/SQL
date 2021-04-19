CREATE TABLE [dbo].[CoachingStatusType]
(
[CoachingStatusTypeId] [int] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_CoachingStatusType_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_CoachingStatusType_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoachingStatusType] ADD CONSTRAINT [PK_CoachingStatusType] PRIMARY KEY CLUSTERED  ([CoachingStatusTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CoachingStatusType] ADD CONSTRAINT [UN_CoachingStatus_Name] UNIQUE NONCLUSTERED  ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
