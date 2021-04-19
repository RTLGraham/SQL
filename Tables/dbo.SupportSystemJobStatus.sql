CREATE TABLE [dbo].[SupportSystemJobStatus]
(
[JobStatus] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_SupportSystemJobStatus_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_SupportSystemJobStatus_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SupportSystemJobStatus] ADD CONSTRAINT [PK_SupportSystemJobStatus] PRIMARY KEY CLUSTERED  ([JobStatus]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
