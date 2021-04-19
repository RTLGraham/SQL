CREATE TABLE [dbo].[LEO_Port]
(
[LeoPortId] [int] NOT NULL IDENTITY(1, 1),
[LeopardId] [int] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NOT NULL CONSTRAINT [DF__LEO_Port__LastOp__639A6E01] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF__LEO_Port__Archiv__648E923A] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_Port] ADD CONSTRAINT [PK_LEO_Port] PRIMARY KEY CLUSTERED  ([LeoPortId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_Port] ADD CONSTRAINT [FK_LEO_Port] FOREIGN KEY ([LeopardId]) REFERENCES [dbo].[LEO_Leopard] ([LeopardId])
GO
