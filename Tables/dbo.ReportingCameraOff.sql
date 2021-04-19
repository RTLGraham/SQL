CREATE TABLE [dbo].[ReportingCameraOff]
(
[ReportingCameraOffId] [bigint] NOT NULL IDENTITY(1, 1),
[CustomerIntId] [int] NULL,
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[Date] [smalldatetime] NOT NULL,
[OffEvents] [int] NULL,
[OnEvents] [int] NULL,
[ThresholdKMH] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportingCameraOff] ADD CONSTRAINT [PK_ReportingCameraOff] PRIMARY KEY CLUSTERED  ([ReportingCameraOffId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ReportingCameraOff] ADD CONSTRAINT [FK_ReportingCameraOff_Customer] FOREIGN KEY ([CustomerIntId]) REFERENCES [dbo].[Customer] ([CustomerIntId])
GO
ALTER TABLE [dbo].[ReportingCameraOff] ADD CONSTRAINT [FK_ReportingCameraOff_Driver] FOREIGN KEY ([DriverIntId]) REFERENCES [dbo].[Driver] ([DriverIntId])
GO
ALTER TABLE [dbo].[ReportingCameraOff] ADD CONSTRAINT [FK_ReportingCameraOff_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
