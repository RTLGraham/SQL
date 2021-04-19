CREATE TABLE [dbo].[SensorLoom]
(
[SensorId] [int] NOT NULL IDENTITY(1, 1),
[SensorHardwareId] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SensorName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_SensorLoomIds_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_SensorLoomIds_Archived] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SensorLoom] ADD CONSTRAINT [PK_SensorLoom] PRIMARY KEY CLUSTERED  ([SensorId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SensorLoomId] ON [dbo].[SensorLoom] ([SensorHardwareId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
