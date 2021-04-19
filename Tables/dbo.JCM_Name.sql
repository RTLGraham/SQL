CREATE TABLE [dbo].[JCM_Name]
(
[NameId] [int] NOT NULL,
[Name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NameTypeId] [int] NOT NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_Name_Arc] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_Name_LastOp] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JCM_Name] ADD CONSTRAINT [PK_JCM_Name] PRIMARY KEY CLUSTERED  ([NameId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[JCM_Name] ADD CONSTRAINT [FK_JCM_Name_Type] FOREIGN KEY ([NameTypeId]) REFERENCES [dbo].[JCM_NameType] ([NameTypeId])
GO
