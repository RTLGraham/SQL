CREATE TABLE [dbo].[VehicleWorkingHours]
(
[VehicleWorkingHoursId] [int] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NOT NULL,
[MonStart] [datetime] NULL,
[MonEnd] [datetime] NULL,
[TueStart] [datetime] NULL,
[TueEnd] [datetime] NULL,
[WedStart] [datetime] NULL,
[WedEnd] [datetime] NULL,
[ThuStart] [datetime] NULL,
[ThuEnd] [datetime] NULL,
[FriStart] [datetime] NULL,
[FriEnd] [datetime] NULL,
[SatStart] [datetime] NULL,
[SatEnd] [datetime] NULL,
[SunStart] [datetime] NULL,
[SunEnd] [datetime] NULL,
[TimeZoneId] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VehicleWorkingHours] ADD CONSTRAINT [PK_VehicleWorkingHours] PRIMARY KEY CLUSTERED  ([VehicleWorkingHoursId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
