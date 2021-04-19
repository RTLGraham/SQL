CREATE TABLE [dbo].[DriverLatestEventTemp]
(
[DriverId] [uniqueidentifier] NOT NULL,
[EventId] [bigint] NULL,
[EventDateTime] [datetime] NULL,
[VehicleId] [uniqueidentifier] NULL,
[CreationCodeId] [smallint] NULL,
[Long] [float] NULL,
[Lat] [float] NULL,
[Heading] [smallint] NULL,
[Speed] [smallint] NULL,
[OdoGPS] [int] NULL,
[OdoRoadSpeed] [int] NULL,
[OdoDashboard] [int] NULL,
[VehicleMode] [int] NULL,
[AnalogIoAlertTypeId] [int] NULL,
[DigitalIO] [tinyint] NULL,
[AnalogData0] [smallint] NULL,
[AnalogData1] [smallint] NULL,
[AnalogData2] [smallint] NULL,
[AnalogData3] [smallint] NULL,
[AnalogData4] [smallint] NULL,
[AnalogData5] [smallint] NULL,
[Archived] [bit] NULL
) ON [PRIMARY]
GO
