CREATE TABLE [dbo].[RTIME]
(
[RTIMEId] [bigint] NOT NULL,
[VehicleIntId] [int] NULL,
[IVHIntId] [int] NULL,
[CreationDateTime] [datetime] NOT NULL,
[Text] [char] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastOperation] [smalldatetime] NOT NULL,
[Archived] [bit] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RTIME] ADD CONSTRAINT [PK_RTIME] PRIMARY KEY CLUSTERED  ([RTIMEId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RTIME] ADD CONSTRAINT [FK_RTIME_IVH] FOREIGN KEY ([IVHIntId]) REFERENCES [dbo].[IVH] ([IVHIntId])
GO
ALTER TABLE [dbo].[RTIME] ADD CONSTRAINT [FK_RTIME_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
