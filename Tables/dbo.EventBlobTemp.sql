CREATE TABLE [dbo].[EventBlobTemp]
(
[EventBlobId] [bigint] NOT NULL IDENTITY(1, 1),
[EventId] [bigint] NULL,
[CustomerIntId] [int] NULL CONSTRAINT [DF_EventBlobTemp_CustomerIntId] DEFAULT ((0)),
[EventDateTime] [datetime] NULL,
[VehicleIntId] [int] NULL,
[DriverIntId] [int] NULL,
[CreationCodeId] [smallint] NULL,
[SeverityId] [smallint] NULL,
[Blob] [varbinary] (max) NULL,
[LastOperation] [smalldatetime] NULL CONSTRAINT [DF_EventBlobTemp_LastOperation] DEFAULT (getdate()),
[Archived] [bit] NULL
) ON [PRIMARY]
GO
