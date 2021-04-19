CREATE TABLE [dbo].[LoneWorking]
(
[LoneWorkingId] [bigint] NOT NULL IDENTITY(1, 1),
[CustomerIntId] [int] NULL,
[DriverId] [uniqueidentifier] NULL,
[VehicleId] [uniqueidentifier] NULL,
[LoneWorkingStart] [datetime] NULL,
[LoneWorkingEnd] [datetime] NULL,
[AlarmTriggeredDateTime] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LoneWorking] ADD CONSTRAINT [PK_LoneWorking] PRIMARY KEY CLUSTERED  ([LoneWorkingId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LoneWorking] ADD CONSTRAINT [FK_LoneWorking_Customer] FOREIGN KEY ([CustomerIntId]) REFERENCES [dbo].[Customer] ([CustomerIntId])
GO
ALTER TABLE [dbo].[LoneWorking] ADD CONSTRAINT [FK_LoneWorking_Driver] FOREIGN KEY ([DriverId]) REFERENCES [dbo].[Driver] ([DriverId])
GO
ALTER TABLE [dbo].[LoneWorking] ADD CONSTRAINT [FK_LoneWorking_Vehicle] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
