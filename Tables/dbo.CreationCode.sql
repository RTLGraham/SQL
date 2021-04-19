CREATE TABLE [dbo].[CreationCode]
(
[CreationCodeId] [smallint] NOT NULL,
[Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CreationCode_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_CreationCode_Archived] DEFAULT ((0)),
[Notes] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CreationCode] ADD CONSTRAINT [PK_CreationCode] PRIMARY KEY CLUSTERED  ([CreationCodeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
