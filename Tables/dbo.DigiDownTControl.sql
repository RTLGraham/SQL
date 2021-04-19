CREATE TABLE [dbo].[DigiDownTControl]
(
[DigiDownTControlId] [int] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NULL,
[DriverIntid] [int] NULL,
[CommandId] [int] NULL,
[CommandDateTime] [datetime] NULL,
[ExpiryDateTime] [datetime] NULL,
[StatusId] [smallint] NULL,
[DaysToDownload] [int] NULL,
[DownloadLimit] [tinyint] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DigidownTControl_DateDriver] ON [dbo].[DigiDownTControl] ([CommandDateTime], [DriverIntid]) INCLUDE ([ExpiryDateTime], [StatusId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DigidownTControl_DateVehicle] ON [dbo].[DigiDownTControl] ([CommandDateTime], [VehicleIntId]) INCLUDE ([ExpiryDateTime], [StatusId]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_DigidownTControl] ON [dbo].[DigiDownTControl] ([CommandId]) ON [PRIMARY]
GO
