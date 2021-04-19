CREATE TABLE [dbo].[CFG_KeyCommand]
(
[KeyCommandId] [int] NOT NULL IDENTITY(1, 1),
[CommandId] [int] NOT NULL,
[KeyId] [int] NOT NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CFG_KeyCommand_LastOperation] DEFAULT (getdate()),
[IndexPos] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CFG_KeyCommand] ADD CONSTRAINT [PK_CFG_KeyCommand] PRIMARY KEY CLUSTERED  ([KeyCommandId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CFG_KeyCommand] ADD CONSTRAINT [FK_CFG_KeyCommand_Command] FOREIGN KEY ([CommandId]) REFERENCES [dbo].[CFG_Command] ([CommandId])
GO
ALTER TABLE [dbo].[CFG_KeyCommand] ADD CONSTRAINT [FK_CFG_KeyCommand_Key] FOREIGN KEY ([KeyId]) REFERENCES [dbo].[CFG_Key] ([KeyId])
GO
