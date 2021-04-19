SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- ==========================================================================================
-- Author:		Graham Pattison
-- Create date: 04/12/2014
-- Description:	Processes data from the LogDataReportingCopy table to create reporting data
--				for Logdata.  
-- ==========================================================================================
CREATE PROCEDURE [dbo].[proc_PopulateReportingLogData]
AS

-- First of all check whether or not this process is still running
-- by trying to create a temprary table
SELECT MyVar = 5 INTO #ReportingLogData

IF @@ERROR <> 0
BEGIN
	-- do nothing!
	SELECT 0
END ELSE

BEGIN

	SET NOCOUNT ON



	-- Mark rows as 'In Process' in LogDataReportingCopy table
	UPDATE dbo.LogDataReportingCopy
	SET Archived = 1
	WHERE Archived = 0

	-- 1. Create and populate a temporary table to hold log data by vehicle
	DECLARE @logdata TABLE
	(
		VehicleIntId INT,
		FirstDate SMALLDATETIME,
		FirstRunTime INT NULL,
		FirstDecelTime INT NULL,
		FirstStatTime INT NULL,
		FirstEcoTime INT NULL,
		FirstTotalDistance FLOAT NULL,
		FirstMovingFuel FLOAT NULL,
		FirstStatFuel FLOAT NULL,
		LastDate SMALLDATETIME,
		LastRunTime INT NULL,
		LastDecelTime INT NULL,
		LastStatTime INT NULL,
		LastEcoTime INT NULL,
		LastTotalDistance FLOAT NULL,
		LastMovingFuel FLOAT NULL,
		LastStatFuel FLOAT NULL,
		PrevRunTime INT NULL,
		PrevDecelTime INT NULL,
		PrevStatTime INT NULL,
		PrevEcoTime INT NULL,
		PrevTotalDistance FLOAT NULL,
		PrevMovingFuel FLOAT NULL,
		PrevStatFuel FLOAT NULL
	)

	-- 1a. Determine the first and last log data records per vehicle as there may be several per vehicle 
	INSERT INTO @logdata (VehicleIntId,FirstDate,FirstRunTime,FirstDecelTime,FirstStatTime,FirstEcoTime,FirstTotalDistance,FirstMovingFuel,FirstStatFuel,LastDate,LastRunTime,LastDecelTime,LastStatTime,LastEcoTime,LastTotalDistance,LastMovingFuel,LastStatFuel)
	SELECT f.VehicleIntId, f.Date, f.RunTime, f.DecelTime, f.StatTime, f.EcoTime, f.TotalDistance, f.MovingFuel, f.StatFuel, l.Date, l.RunTime, l.DecelTime, l.StatTime, l.EcoTime, l.TotalDistance, l.MovingFuel, l.StatFuel
	FROM 
	(
		SELECT r.VehicleIntId, CAST(FLOOR(CAST(LogDateTime AS FLOAT)) AS SMALLDATETIME) AS Date, RunTime, DecelTime, StatTime, EcoTime, TotalDistance, MovingFuel, StatFuel, ROW_NUMBER() OVER(PARTITION BY r.VehicleIntId ORDER BY r.VehicleIntId, r.LogDateTime DESC) AS RowNum
		FROM dbo.LogDataReportingCopy r
	) l
	INNER JOIN 
	(
		SELECT r.VehicleIntId, CAST(FLOOR(CAST(LogDateTime AS FLOAT)) AS SMALLDATETIME) AS Date, RunTime, DecelTime, StatTime, EcoTime, TotalDistance, MovingFuel, StatFuel, ROW_NUMBER() OVER(PARTITION BY r.VehicleIntId ORDER BY r.VehicleIntId, r.LogDateTime ASC) AS RowNum
		FROM dbo.LogDataReportingCopy r
	) f ON l.VehicleIntId = f.VehicleIntId AND l.RowNum = 1 AND f.RowNum = 1

	-- 1b. Determine if there is a previous ReportingLogData record per vehicle (in the previous 7 days)
	UPDATE @logdata
	SET PrevRunTime = rld_old.EndRunTime,
		PrevDecelTime = rld_old.EndDecelTime,
		PrevStatTime = rld_old.EndStatTime,
		PrevEcoTime = rld_old.EndEcoTime,
		PrevTotalDistance = rld_old.EndDistance,
		PrevMovingFuel = rld_old.EndMovingFuel,
		PrevStatFuel = rld_old.EndStatFuel
	FROM @logdata l
	INNER JOIN 
	(
		SELECT r.VehicleIntId, r.EndRunTime, r.EndDecelTime, r.EndStatTime, r.EndEcoTime, r.EndDistance, r.EndMovingFuel, r.EndStatFuel, ROW_NUMBER() OVER(PARTITION BY r.VehicleIntId ORDER BY r.VehicleIntId, r.Date DESC) AS RowNum
		FROM dbo.ReportingLogData r
		INNER JOIN @logdata l ON r.VehicleIntId = l.VehicleIntId
		WHERE r.Date > DATEADD(dd, -7, GETDATE()) -- look back no further than 7 days
	) rld_old ON l.VehicleIntId = rld_old.VehicleIntId AND rld_old.RowNum = 1
	
	-- 2. UPDATE the row in ReportingLogData for today for all rows where a reporting row for today already exists
	UPDATE dbo.ReportingLogData 
	SET	EndRunTime = l.LastRunTime,
		EndDecelTime = l.LastDecelTime,
		EndStatTime = l.LastStatTime,
		EndEcoTime = l.LastEcoTime,
		EndDistance = l.LastTotalDistance,
		EndMovingFuel = l.LastMovingFuel,
		EndStatFuel = l.LastStatFuel,			
		LastOperation = GETUTCDATE()
	FROM @logdata l
	INNER JOIN dbo.ReportingLogData r ON l.VehicleIntId = r.VehicleIntId AND l.FirstDate = r.Date
	
	-- 3. INSERT a row into ReportingLogData for TODAY for all rows where a reporting row for the vehicle for TODAY does not yet exist
	--    but the vehicle has previously reported (so we are able to obtain start data for today)
	INSERT INTO dbo.ReportingLogData (VehicleIntId,Date,StartRunTime,StartDecelTime,StartStatTime,StartEcoTime,StartDistance,StartMovingFuel,StartStatFuel,EndRunTime,EndDecelTime,EndStatTime,EndEcoTime,EndDistance,EndMovingFuel,EndStatFuel,LastOperation,Archived)
	SELECT	ld.VehicleIntId, 
			ld.FirstDate,
			ld.PrevRunTime,
			ld.PrevDecelTime,
			ld.PrevStatTime,
			ld.PrevEcoTime,
			ld.PrevTotalDistance,
			ld.PrevMovingFuel,
			ld.PrevStatFuel,			
			ld.LastRunTime,
			ld.LastDecelTime,
			ld.LastStatTime,
			ld.LastEcoTime,
			ld.LastTotalDistance,
			ld.LastMovingFuel,
			ld.LastStatFuel,
			GETUTCDATE(),
			0
	FROM @logdata ld 
	LEFT JOIN dbo.ReportingLogData r ON ld.VehicleIntId = r.VehicleIntId AND ld.FirstDate = r.Date
	WHERE r.VehicleIntId IS NULL -- row for today does not already exist
	  AND ld.PrevRunTime IS NOT NULL -- only update where a prev row exists

	-- 4. INSERT a row into ReportingLogdata for TODAY for all rows where a reporting row for the vehicle does not yet exist
	--    The START and END data will both come from the incoming log data records as this is the first time we have received log
	--    data from this vehicle
	INSERT INTO dbo.ReportingLogData (VehicleIntId,Date,StartRunTime,StartDecelTime,StartStatTime,StartEcoTime,StartDistance,StartMovingFuel,StartStatFuel,EndRunTime,EndDecelTime,EndStatTime,EndEcoTime,EndDistance,EndMovingFuel,EndStatFuel,LastOperation,Archived)
	SELECT	ld.VehicleIntId, 
			ld.FirstDate,
			ld.FirstRunTime,
			ld.FirstDecelTime,
			ld.FirstStatTime,
			ld.FirstEcoTime,
			ld.FirstTotalDistance,
			ld.FirstMovingFuel,
			ld.FirstStatFuel,			
			ld.LastRunTime,
			ld.LastDecelTime,
			ld.LastStatTime,
			ld.LastEcoTime,
			ld.LastTotalDistance,
			ld.LastMovingFuel,
			ld.LastStatFuel,
			GETUTCDATE(),
			0
	FROM @logdata ld
	WHERE ld.PrevRunTime IS NULL
	
	-- Cleanup Processing tables
	DELETE
	FROM dbo.LogDataReportingCopy
	WHERE Archived = 1
	
	-- Delete temporary table to indicate job has completed
	DROP TABLE #ReportingLogData

END

GO
