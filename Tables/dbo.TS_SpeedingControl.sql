CREATE TABLE [dbo].[TS_SpeedingControl]
(
[SpeedingControlID] [bigint] NOT NULL IDENTITY(1, 1),
[DriverIntId] [int] NULL,
[VehicleIntId] [int] NULL,
[TSStartId] [bigint] NULL,
[TSEndId] [bigint] NULL,
[TSStartDate] [smalldatetime] NULL,
[TSEndDate] [smalldatetime] NULL,
[ProcessInd] [int] NULL
) ON [PRIMARY]
GO
