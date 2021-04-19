CREATE TABLE [dbo].[LEO_Temp_Resource]
(
[LeoResourceId] [int] NOT NULL IDENTITY(1, 1),
[LeopardId] [int] NOT NULL,
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Total] [bigint] NULL,
[Available] [bigint] NULL,
[LastOperation] [smalldatetime] NOT NULL CONSTRAINT [DF__LEO_Temp___LastO__72DCB191] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF__LEO_Temp___Archi__73D0D5CA] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_Temp_Resource] ADD CONSTRAINT [PK_LEO_Temp_Resource] PRIMARY KEY CLUSTERED  ([LeoResourceId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_Temp_Resource] ADD CONSTRAINT [FK_LEO_Temp_Resource] FOREIGN KEY ([LeopardId]) REFERENCES [dbo].[LEO_Leopard] ([LeopardId])
GO
