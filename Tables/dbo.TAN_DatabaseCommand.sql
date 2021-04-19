CREATE TABLE [dbo].[TAN_DatabaseCommand]
(
[Command] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcessInd] [tinyint] NULL,
[VehicleId] [uniqueidentifier] NULL,
[DriverId] [uniqueidentifier] NULL,
[GeofenceId] [uniqueidentifier] NULL,
[UserId] [uniqueidentifier] NULL,
[TriggerDateTime] [datetime] NULL
) ON [PRIMARY]
GO
