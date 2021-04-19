CREATE TABLE [dbo].[KronosAbsenseType]
(
[KronosAbsenseTypeId] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayOrder] [int] NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_KronosAbsenseType_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_KronosAbsenseType_Archived] DEFAULT ((0)),
[CommentReq] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KronosAbsenseType] ADD CONSTRAINT [PK_KronosAbsenseType] PRIMARY KEY CLUSTERED  ([KronosAbsenseTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
