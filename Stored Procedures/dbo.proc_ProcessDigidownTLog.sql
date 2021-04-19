SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_ProcessDigidownTLog] 
AS

BEGIN

	-- Mark unprocessed rows as 'In Process'
	UPDATE dbo.DigiDownTLog
	SET ProcessInd = 0
	WHERE ProcessInd IS NULL

	-- Match corresponding vehicle download rows that have arrived in the log with Commands recorded in the Control table for the current day
	UPDATE dbo.DigiDownTControl
	SET StatusId = CASE WHEN l.Succeeded = 1 THEN 2 ELSE 3 END	
	FROM dbo.DigiDownTControl t
	INNER JOIN dbo.DigiDownTLog l ON l.VehicleIntId = t.VehicleIntId AND t.DriverIntId IS NULL AND FLOOR(CAST(UploadDateTime AS FLOAT)) = FLOOR(CAST(t.CommandDateTime AS FLOAT))
	WHERE l.ProcessInd = 0
	  AND t.StatusId = 1
	  AND t.ExpiryDateTime > GETDATE()
	
	-- Match corresponding driver card download rows that have arrived in the log with Commands recorded in the Control table for the current day
	UPDATE dbo.DigiDownTControl
	SET StatusId = CASE WHEN l.Succeeded = 1 THEN 2 ELSE 3 END	
	FROM dbo.DigiDownTControl t
	INNER JOIN dbo.DigiDownTLog l ON l.VehicleIntId = t.VehicleIntId AND l.DriverIntId = t.DriverIntid AND FLOOR(CAST(UploadDateTime AS FLOAT)) = FLOOR(CAST(t.CommandDateTime AS FLOAT))
	WHERE l.ProcessInd = 0
	  AND t.StatusId = 1
	  AND t.ExpiryDateTime > GETDATE()		

	-- Finally mark rows as processed
	UPDATE dbo.DigiDownTLog
	SET ProcessInd = 1
	WHERE ProcessInd = 0

END



GO
