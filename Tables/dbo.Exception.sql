CREATE TABLE [dbo].[Exception]
(
[ExceptionId] [bigint] NOT NULL IDENTITY(1, 1),
[DriverId] [uniqueidentifier] NULL,
[VehicleId] [uniqueidentifier] NULL,
[TriggerId] [uniqueidentifier] NULL,
[ExceptionTypeId] [smallint] NULL,
[EventDateTime] [datetime] NULL,
[Lat] [float] NULL,
[Long] [float] NULL,
[Location] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Speed] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Exception] ADD CONSTRAINT [PK_Exception] PRIMARY KEY CLUSTERED  ([ExceptionId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Exception_VehicleDate] ON [dbo].[Exception] ([VehicleId], [EventDateTime]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Exception] ADD CONSTRAINT [FK_Exception_Driver] FOREIGN KEY ([DriverId]) REFERENCES [dbo].[Driver] ([DriverId])
GO
ALTER TABLE [dbo].[Exception] ADD CONSTRAINT [FK_Exception_Vehicle] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[Vehicle] ([VehicleId])
GO
