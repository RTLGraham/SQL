CREATE TABLE [dbo].[KB_Folder]
(
[FolderId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerId] [uniqueidentifier] NULL,
[Archived] [bit] NULL CONSTRAINT [DF_KB_Folder_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_KB_Folder_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_Folder] ADD CONSTRAINT [PK_KB_Folder] PRIMARY KEY CLUSTERED  ([FolderId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_Folder] ADD CONSTRAINT [FK_KB_Folder_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([CustomerId])
GO
