CREATE TABLE [dbo].[CAM_Incident]
(
[IncidentId] [bigint] NOT NULL IDENTITY(1, 1),
[EventId] [bigint] NULL,
[EventDateTime] [datetime] NULL,
[CreationCodeId] [smallint] NULL,
[CustomerIntId] [int] NOT NULL CONSTRAINT [DF_CAM_Incident_CustomerIntId] DEFAULT ((0)),
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[CameraIntId] [int] NULL,
[CoachingStatusId] [int] NULL,
[ApiEventId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiMetadataId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_CAM_Incident_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_CAM_Incident_Archived] DEFAULT ((0)),
[MinX] [float] NULL,
[MaxX] [float] NULL,
[MinY] [float] NULL,
[MaxY] [float] NULL,
[MinZ] [float] NULL,
[MaxZ] [float] NULL,
[IsEscalated] [bit] NOT NULL CONSTRAINT [DF__CAM_Incid__IsEsc__3731DBDE] DEFAULT ((0)),
[Lat] [float] NULL,
[Long] [float] NULL,
[Heading] [smallint] NULL,
[Speed] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CAM_Incident] ADD CONSTRAINT [PK_CAM_Incident] PRIMARY KEY CLUSTERED  ([IncidentId]) WITH (FILLFACTOR=80, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAM_Incident_ApiEventId] ON [dbo].[CAM_Incident] ([ApiEventId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAM_Incident_CustomerEventDateTime] ON [dbo].[CAM_Incident] ([CustomerIntId], [EventDateTime]) INCLUDE ([IncidentId], [CreationCodeId], [Lat], [Long]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAM_Incident_Driver] ON [dbo].[CAM_Incident] ([DriverIntId], [CreationCodeId], [EventDateTime]) INCLUDE ([IncidentId], [CoachingStatusId], [VehicleIntId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAM_Incident_EventId] ON [dbo].[CAM_Incident] ([EventId]) INCLUDE ([EventDateTime], [CreationCodeId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_CAM_Incident_Vehicle] ON [dbo].[CAM_Incident] ([VehicleIntId], [CreationCodeId], [EventDateTime], [Archived]) ON [PRIMARY]
GO
