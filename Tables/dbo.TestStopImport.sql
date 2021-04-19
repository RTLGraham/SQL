CREATE TABLE [dbo].[TestStopImport]
(
[TestStopImportID] [int] NOT NULL IDENTITY(1, 1),
[VehicleId] [uniqueidentifier] NULL,
[Registration] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[StopTime] [datetime] NULL,
[Latitude] [float] NULL,
[Longitude] [float] NULL,
[Odometer] [int] NULL,
[Heading] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TestStopImport] ADD CONSTRAINT [PK_TestStopImport] PRIMARY KEY CLUSTERED  ([TestStopImportID]) WITH (IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
