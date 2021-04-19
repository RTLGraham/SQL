CREATE TABLE [dbo].[PassComf]
(
[PassComfId] [bigint] NOT NULL,
[CreationCodeId] [smallint] NOT NULL,
[CreationDateTime] [datetime] NOT NULL,
[ClosureDateTime] [datetime] NOT NULL,
[VehicleIntId] [int] NOT NULL,
[DriverIntId] [int] NOT NULL,
[RouteId] [int] NOT NULL,
[CustomerIntId] [int] NOT NULL,
[DrivingTime] [int] NOT NULL,
[DrivingDistance] [float] NOT NULL,
[Score] [int] NOT NULL,
[RS0Accel] [int] NOT NULL,
[RS0Brake] [int] NOT NULL,
[RS0Corner] [int] NOT NULL,
[RS1Accel] [int] NOT NULL,
[RS1Brake] [int] NOT NULL,
[RS1Corner] [int] NOT NULL,
[RS2Accel] [int] NOT NULL,
[RS2Brake] [int] NOT NULL,
[RS2Corner] [int] NOT NULL,
[RS3Accel] [int] NOT NULL,
[RS3Brake] [int] NOT NULL,
[RS3Corner] [int] NOT NULL,
[RS4Accel] [int] NOT NULL,
[RS4Brake] [int] NOT NULL,
[RS4Corner] [int] NOT NULL,
[RS5Accel] [int] NOT NULL,
[RS5Brake] [int] NOT NULL,
[RS5Corner] [int] NOT NULL,
[RS6Accel] [int] NOT NULL,
[RS6Brake] [int] NOT NULL,
[RS6Corner] [int] NOT NULL,
[RS7Accel] [int] NOT NULL,
[RS7Brake] [int] NOT NULL,
[RS7Corner] [int] NOT NULL,
[RS8Accel] [int] NOT NULL,
[RS8Brake] [int] NOT NULL,
[RS8Corner] [int] NOT NULL,
[RS9Accel] [int] NOT NULL,
[RS9Brake] [int] NOT NULL,
[RS9Corner] [int] NOT NULL,
[LastOperation] [smalldatetime] NOT NULL,
[Archived] [bit] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE TRIGGER [dbo].[trig_PassComfReportingCopy] 
   ON  [dbo].[PassComf] 
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;

	INSERT INTO PassComfReportingCopy
		SELECT	*
		FROM	inserted 
END


GO
ALTER TABLE [dbo].[PassComf] ADD CONSTRAINT [PK_PassComf] PRIMARY KEY CLUSTERED  ([PassComfId]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PassComf] ADD CONSTRAINT [FK_PassComf_CreationCode] FOREIGN KEY ([CreationCodeId]) REFERENCES [dbo].[CreationCode] ([CreationCodeId])
GO
ALTER TABLE [dbo].[PassComf] ADD CONSTRAINT [FK_PassComf_Customer] FOREIGN KEY ([CustomerIntId]) REFERENCES [dbo].[Customer] ([CustomerIntId])
GO
ALTER TABLE [dbo].[PassComf] ADD CONSTRAINT [FK_PassComf_Driver] FOREIGN KEY ([DriverIntId]) REFERENCES [dbo].[Driver] ([DriverIntId])
GO
ALTER TABLE [dbo].[PassComf] ADD CONSTRAINT [FK_PassComf_Route] FOREIGN KEY ([RouteId]) REFERENCES [dbo].[Route] ([RouteID])
GO
ALTER TABLE [dbo].[PassComf] ADD CONSTRAINT [FK_PassComf_Vehicle] FOREIGN KEY ([VehicleIntId]) REFERENCES [dbo].[Vehicle] ([VehicleIntId])
GO
