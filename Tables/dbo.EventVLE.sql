CREATE TABLE [dbo].[EventVLE]
(
[EventId] [bigint] NOT NULL,
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[CreationCodeId] [smallint] NULL,
[Long] [float] NULL,
[Lat] [float] NULL,
[Heading] [smallint] NULL,
[Speed] [smallint] NULL,
[OdoGPS] [int] NULL,
[OdoRoadSpeed] [int] NULL,
[OdoDashboard] [int] NULL,
[EventDateTime] [datetime] NOT NULL,
[DigitalIO] [tinyint] NULL,
[CustomerIntId] [int] NOT NULL,
[AnalogData0] [smallint] NULL,
[AnalogData1] [smallint] NULL,
[AnalogData2] [smallint] NULL,
[AnalogData3] [smallint] NULL,
[AnalogData4] [smallint] NULL,
[AnalogData5] [smallint] NULL,
[LastOperation] [smalldatetime] NULL,
[ProcessInd] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[EventVLE] ADD CONSTRAINT [PK_EventVLE] PRIMARY KEY CLUSTERED  ([EventId]) WITH (FILLFACTOR=100, IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
