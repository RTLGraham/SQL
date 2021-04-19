CREATE TABLE [dbo].[CAM_GPSIn]
(
[GPSInId] [bigint] NOT NULL IDENTITY(1, 1),
[ProjectId] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[VehicleId] [uniqueidentifier] NULL,
[EventDateTime] [datetime] NULL,
[Lat] [float] NULL,
[Long] [float] NULL,
[Speed] [smallint] NULL,
[Heading] [smallint] NULL,
[Distance] [int] NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CAM_GPSIn_LastOperation] DEFAULT (getdate()),
[ProcessInd] [tinyint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_GPSIn] ADD CONSTRAINT [PK_CAM_GPSIn] PRIMARY KEY CLUSTERED  ([GPSInId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAMGPSIn_Project] ON [dbo].[CAM_GPSIn] ([ProjectId], [ProcessInd]) ON [PRIMARY]
GO
