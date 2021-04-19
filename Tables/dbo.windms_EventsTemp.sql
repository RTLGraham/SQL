CREATE TABLE [dbo].[windms_EventsTemp]
(
[VehicleIntId] [int] NULL,
[IVHIntId] [int] NULL,
[DriverIntId] [int] NULL,
[CreationCodeId] [smallint] NULL,
[Long] [float] NULL,
[Lat] [float] NULL,
[Heading] [smallint] NULL,
[Speed] [smallint] NULL,
[TripDistance] [int] NULL,
[EventDateTime] [datetime] NULL,
[DigitalIO] [tinyint] NULL,
[FlagId] [tinyint] NULL,
[LastOperation] [smalldatetime] NULL,
[Archived] [bit] NULL,
[CustomerIntId] [int] NULL,
[EventId] [bigint] NOT NULL
) ON [PRIMARY]
GO
