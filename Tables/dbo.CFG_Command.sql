CREATE TABLE [dbo].[CFG_Command]
(
[CommandId] [int] NOT NULL IDENTITY(1, 1),
[CategoryId] [int] NOT NULL,
[IVHTypeId] [int] NOT NULL,
[CommandRoot] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NOT NULL CONSTRAINT [DF_CFG_Command_Archived] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CFG_Command_LastOperation] DEFAULT (getdate()),
[ExcludeResend] [bit] NULL CONSTRAINT [DF__CFG_Comma__Exclu__3381468B] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CFG_Command] ADD CONSTRAINT [PK_CFG_Command] PRIMARY KEY CLUSTERED  ([CommandId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CFG_Command] ADD CONSTRAINT [FK_CFG_Command_Category] FOREIGN KEY ([CategoryId]) REFERENCES [dbo].[CFG_Category] ([CategoryId])
GO
ALTER TABLE [dbo].[CFG_Command] ADD CONSTRAINT [FK_CFG_Command_IVHType] FOREIGN KEY ([IVHTypeId]) REFERENCES [dbo].[IVHType] ([IVHTypeId])
GO
