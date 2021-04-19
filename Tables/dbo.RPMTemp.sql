CREATE TABLE [dbo].[RPMTemp]
(
[RPMId] [bigint] NOT NULL IDENTITY(1, 1),
[VehicleIntId] [int] NULL,
[IVHIntId] [int] NULL,
[CreationDateTime] [datetime] NOT NULL,
[Text] [char] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastOperation] [smalldatetime] NOT NULL,
[Archived] [bit] NOT NULL
) ON [PRIMARY]
GO
