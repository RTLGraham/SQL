CREATE TABLE [dbo].[NKVDAlerts]
(
[NKVDAlertId] [int] NOT NULL IDENTITY(1, 1),
[NKVDSubject] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NKVDBody] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDateTime] [datetime] NULL,
[ProcessInd] [bit] NULL
) ON [PRIMARY]
GO
