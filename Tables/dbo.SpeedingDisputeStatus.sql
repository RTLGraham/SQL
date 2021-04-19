CREATE TABLE [dbo].[SpeedingDisputeStatus]
(
[SpeedingDisputeStatusId] [int] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_SpeedingDisputeStatus_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_SpeedingDisputeStatus_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SpeedingDisputeStatus] ADD CONSTRAINT [PK_SpeedingDisputeStatus] PRIMARY KEY CLUSTERED  ([SpeedingDisputeStatusId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SpeedingDisputeStatus] ADD CONSTRAINT [UN_SpeedingDisputeStatus_Name] UNIQUE NONCLUSTERED  ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
