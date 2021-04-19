CREATE TABLE [dbo].[Sensor]
(
[SensorId] [smallint] NOT NULL IDENTITY(1, 1),
[SensorType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SensorIndex] [tinyint] NOT NULL,
[CreationCodeIdActive] [smallint] NULL,
[CreationCodeIdInactive] [smallint] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_Sensor_LastOperation] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Sensor] ADD CONSTRAINT [PK_Sensor] PRIMARY KEY CLUSTERED  ([SensorId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Sensor] WITH NOCHECK ADD CONSTRAINT [FK_Sensor_Active] FOREIGN KEY ([CreationCodeIdActive]) REFERENCES [dbo].[CreationCode] ([CreationCodeId])
GO
ALTER TABLE [dbo].[Sensor] WITH NOCHECK ADD CONSTRAINT [FK_Sensor_Inactive] FOREIGN KEY ([CreationCodeIdInactive]) REFERENCES [dbo].[CreationCode] ([CreationCodeId])
GO
