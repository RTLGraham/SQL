CREATE TABLE [dbo].[AuditStatusType]
(
[AuditStatusTypeId] [int] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_AuditStatusType_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_AuditStatusType_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AuditStatusType] ADD CONSTRAINT [PK_AuditStatusType] PRIMARY KEY CLUSTERED  ([AuditStatusTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AuditStatusType] ADD CONSTRAINT [UN_AuditStatus_Name] UNIQUE NONCLUSTERED  ([Name]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
