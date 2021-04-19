CREATE TABLE [dbo].[STOPITemp]
(
[STOPIId] [bigint] NOT NULL IDENTITY(1, 1),
[Text] [char] (1500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LastOperation] [smalldatetime] NOT NULL,
[Archived] [bit] NOT NULL,
[CustomerIntId] [int] NOT NULL,
[EventId] [bigint] NULL
) ON [PRIMARY]
GO
