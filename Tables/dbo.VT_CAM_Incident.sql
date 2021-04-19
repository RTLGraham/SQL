CREATE TABLE [dbo].[VT_CAM_Incident]
(
[IncidentId] [bigint] NOT NULL IDENTITY(1, 1),
[EventId] [bigint] NULL,
[EventDateTime] [datetime] NULL,
[CreationCodeId] [smallint] NULL,
[CustomerIntId] [int] NOT NULL CONSTRAINT [DF_VT_CAM_Incident_CustomerIntId] DEFAULT ((0)),
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[CameraIntId] [int] NULL,
[CoachingStatusId] [int] NULL,
[ApiEventId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApiMetadataId] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_VT_CAM_Incident_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_VT_CAM_Incident_Archived] DEFAULT ((0)),
[MinX] [float] NULL,
[MaxX] [float] NULL,
[MinY] [float] NULL,
[MaxY] [float] NULL,
[MinZ] [float] NULL,
[MaxZ] [float] NULL,
[IsEscalated] [bit] NOT NULL CONSTRAINT [DF__VT_CAM_In__IsEsc__0B1E4F76] DEFAULT ((0)),
[Lat] [float] NULL,
[Long] [float] NULL,
[Heading] [smallint] NULL,
[Speed] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VT_CAM_Incident] ADD CONSTRAINT [PK_VT_CAM_Incident] PRIMARY KEY CLUSTERED  ([IncidentId]) WITH (IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
