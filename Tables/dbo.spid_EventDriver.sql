CREATE TABLE [dbo].[spid_EventDriver]
(
[Spid] [int] NOT NULL,
[VehicleIntId] [int] NULL,
[EventTime] [datetime] NULL,
[CustomerIntId] [int] NULL,
[DriverName] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [spid_EventDriver_ix] ON [dbo].[spid_EventDriver] ([Spid]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
