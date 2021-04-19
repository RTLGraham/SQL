CREATE TABLE [dbo].[DeliveryNotification]
(
[NotificationID] [bigint] NOT NULL IDENTITY(1, 1),
[DestinationID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DriverID] [uniqueidentifier] NULL,
[VehicleID] [uniqueidentifier] NOT NULL,
[CustomerID] [uniqueidentifier] NULL,
[GeofenceID] [uniqueidentifier] NULL,
[GeofenceLatitude] [float] NULL,
[GeofenceLongitude] [float] NULL,
[GeofenceRadius] [float] NULL,
[TimeDestinationIDEntered] [smalldatetime] NOT NULL,
[CommandID] [int] NULL,
[TimeCommandCreated] [smalldatetime] NULL,
[TimeCommandAcknowledged] [smalldatetime] NULL,
[TimeGeofenceEntered] [smalldatetime] NULL,
[NotificationType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NotificationEmailRecipients] [xml] NULL,
[TimeNotificationEmailSent] [smalldatetime] NULL,
[TimeNotificationInitiated] [smalldatetime] NULL,
[TelephoneNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeCallEnded] [smalldatetime] NULL,
[CallDuration] [int] NULL,
[CallAttempts] [int] NULL,
[CallResult] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeVehicleArrived] [smalldatetime] NULL,
[DeliveryNotificationStatus] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsServerSide] [bit] NULL CONSTRAINT [DF__DeliveryN__IsSer__69D3359B] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DeliveryNotification] ADD CONSTRAINT [PK_DeliveryNotification] PRIMARY KEY CLUSTERED  ([NotificationID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DeliveryNotification] ADD CONSTRAINT [FK_DeliveryNotification_Customer] FOREIGN KEY ([CustomerID]) REFERENCES [dbo].[Customer] ([CustomerId])
GO
ALTER TABLE [dbo].[DeliveryNotification] ADD CONSTRAINT [FK_DeliveryNotification_Driver] FOREIGN KEY ([DriverID]) REFERENCES [dbo].[Driver] ([DriverId])
GO
ALTER TABLE [dbo].[DeliveryNotification] ADD CONSTRAINT [FK_DeliveryNotification_Vehicle] FOREIGN KEY ([VehicleID]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
ALTER TABLE [dbo].[DeliveryNotification] ADD CONSTRAINT [FK_DeliveryNotification_VehicleCommand] FOREIGN KEY ([CommandID]) REFERENCES [dbo].[VehicleCommand] ([CommandId])
GO
