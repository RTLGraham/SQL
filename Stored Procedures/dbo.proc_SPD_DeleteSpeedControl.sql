SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE PROCEDURE [dbo].[proc_SPD_DeleteSpeedControl]

(@SpeedingControlIds VARCHAR(MAX))

AS
BEGIN
	
	DELETE
	FROM dbo.TS_SpeedingControl 
	WHERE SpeedingControlID IN (SELECT Value FROM dbo.Split(@SpeedingControlIds, ','))

END	

GO
