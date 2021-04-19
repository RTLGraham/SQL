CREATE TABLE [dbo].[SpeedwiseLog]
(
[ScanTimeStart] [datetime] NOT NULL,
[ScanTimeEnd] [datetime] NOT NULL,
[ScanTimeActual] [datetime] NOT NULL,
[EventCount] [int] NULL,
[ExecutionTime] [datetime] NULL
) ON [PRIMARY]
GO
