CREATE TABLE [dbo].[TemperatureStatus]
(
[VehicleId] [uniqueidentifier] NOT NULL,
[Ack] [bit] NULL,
[AckReason] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AckDateTime] [datetime] NULL,
[AckUserId] [uniqueidentifier] NULL,
[AnalogData0] [smallint] NULL,
[AnalogData1] [smallint] NULL,
[AnalogData2] [smallint] NULL,
[AnalogData3] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TemperatureStatus] WITH NOCHECK ADD CONSTRAINT [FK_TemperatureStatus_VehicleId] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
