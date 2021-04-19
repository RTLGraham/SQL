CREATE TABLE [dbo].[KB_File]
(
[FileId] [int] NOT NULL IDENTITY(1, 1),
[FName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerId] [uniqueidentifier] NULL,
[DurationSecs] [int] NULL,
[Url] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BucketName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileTypeId] [smallint] NULL,
[Archived] [bit] NULL CONSTRAINT [DF_KB_File_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_KB_File_LastOperation] DEFAULT (getdate()),
[Ext] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Acknowledge] [bit] NULL,
[FileIdCustom] [varchar] (65) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_File] ADD CONSTRAINT [PK_KB_File] PRIMARY KEY CLUSTERED  ([FileId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KB_File] ADD CONSTRAINT [FK_KB_File_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([CustomerId])
GO
ALTER TABLE [dbo].[KB_File] ADD CONSTRAINT [FK_KB_File_Type] FOREIGN KEY ([FileTypeId]) REFERENCES [dbo].[KB_FileType] ([FileTypeId])
GO
