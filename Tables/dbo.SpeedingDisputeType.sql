CREATE TABLE [dbo].[SpeedingDisputeType]
(
[SpeedingDisputeTypeId] [int] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_SpeedingDisputeType_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_SpeedingDisputeType_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SpeedingDisputeType] ADD CONSTRAINT [PK_SpeedingDisputeType] PRIMARY KEY CLUSTERED  ([SpeedingDisputeTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SpeedingDisputeType] ADD CONSTRAINT [UN_SpeedingDispute_Name] UNIQUE NONCLUSTERED  ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
