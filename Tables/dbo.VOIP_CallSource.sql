CREATE TABLE [dbo].[VOIP_CallSource]
(
[CallSourceId] [int] NOT NULL IDENTITY(1, 1),
[Name] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_VOIP_CallSource_LastOp] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_VOIP_CallSource_Arc] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOIP_CallSource] ADD CONSTRAINT [PK_VOIP_CallSource] PRIMARY KEY CLUSTERED  ([CallSourceId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
