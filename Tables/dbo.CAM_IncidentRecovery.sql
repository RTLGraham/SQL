CREATE TABLE [dbo].[CAM_IncidentRecovery]
(
[IncidentRecoveryId] [int] NOT NULL IDENTITY(1, 1),
[EventId] [bigint] NULL,
[IncidentId] [bigint] NULL,
[VehicleIntId] [int] NULL,
[Lat] [float] NULL,
[Long] [float] NULL,
[Speed] [smallint] NULL,
[Heading] [smallint] NULL
) ON [PRIMARY]
GO
