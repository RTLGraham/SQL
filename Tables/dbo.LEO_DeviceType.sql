CREATE TABLE [dbo].[LEO_DeviceType]
(
[DeviceTypeId] [int] NOT NULL IDENTITY(1, 1),
[Name] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Archived] [bit] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF__LEO_Devic__LastO__50BCA3B7] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LEO_DeviceType] ADD CONSTRAINT [PK_LEO_DeviceTypeId] PRIMARY KEY CLUSTERED  ([DeviceTypeId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
