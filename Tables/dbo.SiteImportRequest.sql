CREATE TABLE [dbo].[SiteImportRequest]
(
[SiteImportRequestID] [int] NOT NULL IDENTITY(1, 1),
[UserID] [uniqueidentifier] NOT NULL,
[Name] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RequestDate] [datetime] NOT NULL,
[ExecutionStartDate] [datetime] NULL,
[CompletionDate] [datetime] NULL,
[Status] [smallint] NOT NULL CONSTRAINT [DF_SiteImportRequest_Status] DEFAULT ((1)),
[SiteCount] [int] NOT NULL,
[RiakFileURL] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastOperation] [datetime] NOT NULL CONSTRAINT [DF_SiteImportRequest_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_SiteImportRequest_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SiteImportRequest] ADD CONSTRAINT [PK_SiteImportRequest] PRIMARY KEY NONCLUSTERED  ([SiteImportRequestID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SiteImportRequest] WITH NOCHECK ADD CONSTRAINT [FK_SiteImportRequest_Status] FOREIGN KEY ([Status]) REFERENCES [dbo].[SiteImportStatus] ([SiteImportStatusId])
GO
