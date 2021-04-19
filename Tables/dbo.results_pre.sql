CREATE TABLE [dbo].[results_pre]
(
[VehicleId] [uniqueidentifier] NULL,
[Registration] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventTime] [datetime] NULL,
[UtilisationType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreationCodeId] [int] NULL,
[OnOff] [bit] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_results_pre] ON [dbo].[results_pre] ([VehicleId], [UtilisationType], [OnOff], [EventTime]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
