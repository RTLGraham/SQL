CREATE TABLE [dbo].[DriverNotification]
(
[DriverNotificationId] [int] NOT NULL IDENTITY(1, 1),
[VehicleId] [uniqueidentifier] NOT NULL,
[Status] [int] NOT NULL,
[LastOperation] [datetime] NOT NULL CONSTRAINT [DF_DriverNotification_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NOT NULL CONSTRAINT [DF_DriverNotification_Archived] DEFAULT ((0)),
[UserId] [uniqueidentifier] NULL,
[CommandId] [int] NULL,
[EventId] [bigint] NULL,
[Long] [float] NULL,
[Lat] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DriverNotification] ADD CONSTRAINT [PK_DriverNotification] PRIMARY KEY CLUSTERED  ([DriverNotificationId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
