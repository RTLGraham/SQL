CREATE TABLE [dbo].[JCM_NameType]
(
[NameTypeId] [int] NOT NULL,
[Name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_NameType_Arc] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_NameType_LastOp] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JCM_NameType] ADD CONSTRAINT [PK_JCM_NameType] PRIMARY KEY CLUSTERED  ([NameTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
