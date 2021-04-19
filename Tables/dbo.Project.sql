CREATE TABLE [dbo].[Project]
(
[ProjectId] [int] NOT NULL IDENTITY(1, 1),
[Project] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CustomerId] [uniqueidentifier] NOT NULL,
[ApiUrl] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiUser] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiPassword] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastIncidentId] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_Project_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_Project_LastOperation] DEFAULT (getdate()),
[BucketName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Project] ADD CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED  ([ProjectId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Project_Project] ON [dbo].[Project] ([Project]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Project] ADD CONSTRAINT [FK_Project_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([CustomerId])
GO
