CREATE TABLE [dbo].[BulkInserts]
(
[EventCount] [int] NULL,
[InsertDateTime] [datetime] NOT NULL,
[MilliSecondsTaken] [int] NULL,
[MilliSecondsEventsData] [int] NULL,
[MilliSecondsVehiclesLatestEvents] [int] NULL,
[MilliSecondsAccums] [int] NULL,
[MilliSecondsSnapshots] [int] NULL,
[MilliSecondsVorads] [int] NULL,
[MilliSecondsTotal] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BulkInserts] ADD CONSTRAINT [PK_BulkInserts] PRIMARY KEY CLUSTERED  ([InsertDateTime]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
