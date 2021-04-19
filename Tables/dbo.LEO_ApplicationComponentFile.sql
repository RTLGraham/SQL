CREATE TABLE [dbo].[LEO_ApplicationComponentFile]
(
[LEO_ApplicationComponentFileId] [int] NOT NULL IDENTITY(1, 1),
[LeopardId] [int] NOT NULL,
[ApplicationComponentId] [int] NOT NULL,
[Version] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [datetime] NULL,
[Size] [bigint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_ApplicationComponentFile] ADD CONSTRAINT [PK_LEO_LEO_ApplicationComponentFile] PRIMARY KEY CLUSTERED  ([LEO_ApplicationComponentFileId]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_ApplicationComponentFile] ADD CONSTRAINT [FK_LEO_ApplicationComponentFile_ApplicationComponent] FOREIGN KEY ([ApplicationComponentId]) REFERENCES [dbo].[LEO_ApplicationComponent] ([ApplicationComponentId])
GO
ALTER TABLE [dbo].[LEO_ApplicationComponentFile] ADD CONSTRAINT [FK_LEO_ApplicationComponentFile_Leopard] FOREIGN KEY ([LeopardId]) REFERENCES [dbo].[LEO_Leopard] ([LeopardId])
GO
