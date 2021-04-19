CREATE TABLE [dbo].[MessageVehicle]
(
[MessageId] [int] NOT NULL,
[VehicleId] [uniqueidentifier] NOT NULL,
[UserId] [uniqueidentifier] NULL,
[CommandId] [int] NULL,
[TimeSent] [datetime] NOT NULL,
[MessageStatusHardwareId] [int] NULL CONSTRAINT [DF_MessageVehicle_Sent] DEFAULT ((0)),
[MessageStatusWetwareId] [int] NULL,
[LastModified] [datetime] NULL CONSTRAINT [DF_MessageVehicle_LastModified] DEFAULT (getdate()),
[Archived] [bit] NULL CONSTRAINT [DF_MessageVehicle_Archived] DEFAULT ((0)),
[HasBeenDeleted] [bit] NULL CONSTRAINT [DF_MessageVehicle_IsDeleted] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageVehicle] ADD CONSTRAINT [PK_MessageVehicle_1] PRIMARY KEY CLUSTERED  ([MessageId], [VehicleId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MessageVehicle] ADD CONSTRAINT [FK_MessageVehicle_MessageStatusHardware] FOREIGN KEY ([MessageStatusHardwareId]) REFERENCES [dbo].[MessageStatus] ([MessageStatusId])
GO
ALTER TABLE [dbo].[MessageVehicle] ADD CONSTRAINT [FK_MessageVehicle_MessageStatusWetware] FOREIGN KEY ([MessageStatusWetwareId]) REFERENCES [dbo].[MessageStatus] ([MessageStatusId])
GO
ALTER TABLE [dbo].[MessageVehicle] ADD CONSTRAINT [FK_MessageVehicle_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([UserID])
GO
