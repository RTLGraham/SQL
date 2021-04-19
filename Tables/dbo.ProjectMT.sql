CREATE TABLE [dbo].[ProjectMT]
(
[ProjectMTId] [int] NOT NULL IDENTITY(1, 1),
[CustomerId] [uniqueidentifier] NOT NULL,
[CompanyId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ApiUrl] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiUser] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiPassword] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastId] [int] NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_ProjectMT_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_ProjectMT_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProjectMT] ADD CONSTRAINT [PK_ProjectMT] PRIMARY KEY CLUSTERED  ([ProjectMTId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProjectMT] ADD CONSTRAINT [FK_ProjectMT_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([CustomerId])
GO
