CREATE TABLE [dbo].[TescoIncident]
(
[IncidentId] [int] NOT NULL IDENTITY(1, 1),
[TescoRecordType] [smallint] NOT NULL,
[DriverIntId] [int] NOT NULL,
[VehicleIntId] [int] NULL,
[QuickNumber] [int] NULL,
[Reference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncidentType] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncidentDateTime] [datetime] NULL,
[ReportedDateTime] [datetime] NULL,
[ARBGrade] [smallint] NULL,
[ARBDate] [smalldatetime] NULL,
[Description] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Outcome] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DriverTrainer] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrainingActionedDate] [smalldatetime] NULL,
[RoadSpeedLimit] [smallint] NULL,
[Speed] [smallint] NULL,
[TPApproxSpeed] [smallint] NULL,
[RoadWidth] [smallint] NULL,
[RoadType] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TPLocation] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ParkingLocation] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PayloadDoors] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Visibility] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Weather] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OtherInformation] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TPWitnessComments] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DSCMNextSteps] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Notes] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedBy] [uniqueidentifier] NULL,
[ModifiedBy] [uniqueidentifier] NULL,
[DeletedDateTime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TescoIncident] ADD CONSTRAINT [PK_TescoIncident] PRIMARY KEY CLUSTERED  ([IncidentId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
