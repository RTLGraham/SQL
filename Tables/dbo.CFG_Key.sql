CREATE TABLE [dbo].[CFG_Key]
(
[KeyId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_CFG_Key_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CFG_Key_LastOperation] DEFAULT (getdate()),
[MinValue] [float] NULL,
[MaxValue] [float] NULL,
[MinDate] [datetime] NULL,
[MaxDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CFG_Key] ADD CONSTRAINT [PK_CFG_Key] PRIMARY KEY CLUSTERED  ([KeyId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
