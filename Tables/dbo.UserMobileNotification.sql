CREATE TABLE [dbo].[UserMobileNotification]
(
[UserMobileNotificationId] [uniqueidentifier] NOT NULL,
[CreationCodeId] [smallint] NOT NULL,
[EventId] [bigint] NULL,
[CustomerIntId] [int] NOT NULL,
[VehicleIntID] [int] NULL,
[DriverIntId] [int] NULL,
[ApplicationId] [smallint] NULL,
[Long] [float] NULL,
[Lat] [float] NULL,
[Heading] [smallint] NULL,
[Speed] [smallint] NULL,
[TripDistance] [int] NULL,
[DataName] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataString] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataInt] [int] NULL,
[DataFloat] [float] NULL,
[DataBit] [bit] NULL,
[TriggerDateTime] [datetime] NULL,
[ProcessInd] [smallint] NOT NULL CONSTRAINT [DF__UserMobileNotification_ProcessInd] DEFAULT ((0)),
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF__UserMobileNotification_LastOperation] DEFAULT (getdate()),
[GeofenceId] [uniqueidentifier] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UserMobileNotification] ADD CONSTRAINT [PK_UserMobileNotification] PRIMARY KEY CLUSTERED  ([UserMobileNotificationId]) ON [PRIMARY]
GO
