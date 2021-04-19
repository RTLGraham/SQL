CREATE TABLE [dbo].[A9A11CopSWCommands]
(
[VehicleId] [uniqueidentifier] NULL,
[IVHId] [uniqueidentifier] NULL,
[DeviceTypeId] [int] NULL,
[Command] [varchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SentDateTime] [datetime] NULL,
[ProcessInd] [tinyint] NULL
) ON [PRIMARY]
GO
