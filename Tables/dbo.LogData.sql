CREATE TABLE [dbo].[LogData]
(
[LogDataId] [bigint] NOT NULL,
[VehicleIntId] [int] NULL,
[IVHId] [int] NULL,
[LogNumber] [int] NOT NULL,
[LogDateTime] [datetime] NOT NULL,
[RunTime] [int] NOT NULL,
[DecelTime] [int] NOT NULL,
[StatTime] [int] NOT NULL,
[EcoTime] [int] NOT NULL,
[TotalDistance] [float] NULL,
[MovingFuel] [float] NOT NULL,
[StatFuel] [float] NOT NULL,
[LastOperation] [smalldatetime] NULL,
[Archived] [bit] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[trig_LogDataReportingCopy] 
   ON  [dbo].[LogData] 
   AFTER INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO LogDataReportingCopy
		SELECT	*
		FROM	inserted 

END

GO
ALTER TABLE [dbo].[LogData] ADD CONSTRAINT [PK_LogData] PRIMARY KEY CLUSTERED  ([LogDataId]) WITH (IGNORE_DUP_KEY=ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LogData_VehicleDate] ON [dbo].[LogData] ([VehicleIntId], [LogDateTime]) ON [PRIMARY]
GO
