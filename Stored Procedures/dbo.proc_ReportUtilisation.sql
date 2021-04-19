SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportUtilisation]
(
	@vids NVARCHAR(MAX) = NULL, 
	@sdate DATETIME = NULL, 
	@edate DATETIME = NULL,
    @uid UNIQUEIDENTIFIER = NULL
)
AS

--DECLARE	@sdate DATETIME,
--		@edate DATETIME,
--		@uid UNIQUEIDENTIFIER,
--		@vids NVARCHAR(MAX)
--		
----SET @vids = N'02EA55B8-EB47-4A27-8BAB-18682C6DA0F2,2243BCEB-95B2-478D-9F0E-BEF4E8420032'
----SET @vids = N'2243BCEB-95B2-478D-9F0E-BEF4E8420032'
--SET @vids = N'299C2A48-BD61-42BF-9AE3-4A96CEC0DFE1,3288D437-AB78-4D72-8E5A-3A6537029361'
----SET @vids = N'CC70821A-0A56-4EE6-8C85-1CC13E30C27F'
--
--SET @uid = N'1129FF7B-89EC-489A-BF78-FFF004DECBED'
--SET @sdate = '2013-07-01 00:00'
--SET @edate = '2013-07-01 23:59'

/****************************************************************************************************/
/*                                    Utilisation Report                                            */
/*                                    ------------------                                            */
/* This report will calculate the digital ON and OFF durations based on any digital inputs received */
/* It will calculate the Key Off duration based on Key On/Off events                                */
/* The Digital ON figure is then adjusted by subtracting the Key Off and Digital OFF durations      */
/* from the total duration. (This is because a unit can have Digital ON whilst keyed off, but this  */
/* is not calculated as Green Utilisation.)															*/
/*											                                                        */
/*	2/7/13: Rewritten to calculate 4 combination states of key on/off and digital on/off.			*/
/*			Green utilisation is no longer calculated based upon the other two utilisation states	*/
/****************************************************************************************************/

DECLARE @s_date DATETIME,
		@e_date DATETIME
SET @s_date = [dbo].TZ_ToUTC(@sdate,default,@uid)
SET @e_date = [dbo].TZ_ToUTC(@edate,default,@uid)

DECLARE @results_pre TABLE
(
	RowNum INT,
	VehicleId UNIQUEIDENTIFIER,
	Registration NVARCHAR(MAX),
	EventTime DATETIME,
	UtilisationType NVARCHAR(10),
	CreationCodeId INT,
	OnOff BIT,
	CombinedType NVARCHAR(20),
	Duration INT
)

INSERT INTO @results_pre (RowNum, VehicleId, Registration, EventTime, UtilisationType, CreationCodeId, OnOff) 
SELECT ROW_NUMBER() OVER(PARTITION BY x.VehicleId ORDER BY x.VehicleId, x.EventTime), x.*
FROM 
	(SELECT v.VehicleId, v.Registration, [dbo].[TZ_GetTime]( e.EventDateTime, default, @uid) as EventTime,
		'Digital' AS UtilisationType, e.CreationCodeId,
		dbo.[GetDioOnOff](v.VehicleId, s.SensorId, e.CreationCodeId) AS OnOff
	FROM dbo.Event e 
		INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.VehicleSensor vs ON vs.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.Sensor s ON vs.SensorId = s.SensorId
	WHERE e.EventDateTime BETWEEN @s_date AND @e_date 
	  AND (e.CreationCodeId = s.CreationCodeIdActive OR e.CreationCodeId = s.CreationCodeIdInactive)
	  AND v.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ','))

	UNION 

	SELECT v.VehicleId, v.Registration, [dbo].[TZ_GetTime]( e.EventDateTime, default, @uid) as EventTime,
		'Key' AS UtilisationType, e.CreationCodeId,
		CASE WHEN e.CreationCodeId = 4 THEN 1 ELSE 0 END AS OnOff
	FROM dbo.Event e 
		INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
	WHERE e.EventDateTime BETWEEN @s_date AND @e_date 
	  AND e.CreationCodeId IN (4,5)
	  AND v.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ','))
	) x

DECLARE @results TABLE
(
	VehicleId UNIQUEIDENTIFIER,
	Registration NVARCHAR(MAX),
	UtilisationType NVARCHAR(20),
	OnOff BIT,
	StartTime DATETIME,
	EndTime DATETIME,
	Duration INT
)

-- The following inserts group and sum all the known digital activity between the start and end dates
-- Inital state at @sdate will NOT be known at this stage
-- This section needs amending to cater for more than one dio in operation at the same time (the min() and datediff() calcs will be incorrect)
INSERT INTO @results (VehicleId, Registration, UtilisationType, OnOff, StartTime, EndTime, Duration)
	SELECT r1.VehicleId, r1.Registration, r1.UtilisationType, r1.OnOff, r1.EventTime AS StartTime, MIN(ISNULL(r2.EventTime,@e_date)) AS EndTime, DATEDIFF(ss, r1.EventTime, MIN(ISNULL(r2.EventTime,@e_date))) AS Duration
	FROM @results_pre r1
	LEFT OUTER JOIN @results_pre r2 ON r1.UtilisationType = r2.UtilisationType AND r1.VehicleId = r2.VehicleId AND r2.EventTime > r1.EventTime AND r2.OnOff = 0 AND r1.OnOff = 1
	WHERE r1.OnOff = 1
	GROUP BY r1.VehicleId, r1.Registration, r1.UtilisationType, r1.OnOff, r1.EventTime, r1.CreationCodeId

INSERT INTO @results (VehicleId, Registration, UtilisationType, OnOff, StartTime, EndTime, Duration)
	SELECT r1.VehicleId, r1.Registration, r1.UtilisationType, r1.OnOff, r1.EventTime AS StartTime, MIN(ISNULL(r2.EventTime,@e_date)) AS EndTime, DATEDIFF(ss, r1.EventTime, MIN(ISNULL(r2.EventTime,@e_date))) AS Duration
	FROM @results_pre r1
	LEFT OUTER JOIN @results_pre r2 ON r1.UtilisationType = r2.UtilisationType AND r1.VehicleId = r2.VehicleId AND r2.EventTime > r1.EventTime AND r2.OnOff = 1 AND r1.OnOff = 0
	WHERE r1.OnOff = 0
	GROUP BY r1.VehicleId, r1.Registration, r1.UtilisationType, r1.OnOff, r1.EventTime, r1.CreationCodeId

-- Need to determine the state between the first digital activity and the start date
-- Will assume that the opening state is the complement of the first known state change
INSERT INTO @results (VehicleId, Registration, UtilisationType, OnOff, StartTime, EndTime, Duration)
	SELECT VehicleId, Registration, UtilisationType, ~OnOff AS OnOff, @s_date, StartTime, DATEDIFF(ss, @s_date, StartTime)
	FROM 
	(SELECT  ROW_NUMBER() OVER(PARTITION BY VehicleId, UtilisationType ORDER BY StartTime) AS RowNumber, * FROM @results) FirstDigital
	WHERE RowNumber = 1

-- Now update the original @results_pre table to identify the combined utilisation and key positions on each transition event
UPDATE @results_pre
SET CombinedType = CASE WHEN rp.UtilisationType = 'Key'
				   THEN CASE WHEN rp.OnOff = 0 
						THEN CASE WHEN ISNULL(r.OnOff,0) = 0 THEN 'KeyOffDigitalOff' ELSE 'KeyOffDigitalOn' END
						ELSE CASE WHEN ISNULL(r.OnOff,0) = 0 THEN 'KeyOnDigitalOff' ELSE 'KeyOnDigitalOn' END
						END
				   ELSE CASE WHEN rp.OnOff = 0 
						THEN CASE WHEN ISNULL(r.OnOff,0) = 0 THEN 'KeyOffDigitalOff' ELSE 'KeyOnDigitalOff' END
						ELSE CASE WHEN ISNULL(r.OnOff,0) = 0 THEN 'KeyOffDigitalOn' ELSE 'KeyOnDigitalOn' END
						END
				   END
FROM @results_pre rp
LEFT JOIN @results r ON rp.UtilisationType != r.UtilisationType AND rp.EventTime BETWEEN r.StartTime AND r.EndTime AND r.VehicleId = rp.VehicleId

-- Insert the start of day states into @results_pre
INSERT INTO @results_pre (RowNum, VehicleId, Registration, EventTime, UtilisationType, CombinedType)
SELECT 0, rp.VehicleId, rp.Registration, r.StartTime, r.UtilisationType, 
				   CASE WHEN rp.UtilisationType = 'Key'
						THEN CASE rp.CombinedType 
							WHEN 'KeyOffDigitalOff' THEN 'KeyOnDigitalOff'
							WHEN 'KeyOffDigitalOn' THEN 'KeyOnDigitalOn'
							WHEN 'KeyOnDigitalOff' THEN 'KeyOffDigitalOff'
							WHEN 'KeyOnDigitalOn' THEN 'KeyOffDigitalOn'
						END
				   ELSE CASE rp.CombinedType 
							WHEN 'KeyOffDigitalOff' THEN 'KeyOffDigitalOn'
							WHEN 'KeyOffDigitalOn' THEN 'KeyOffDigitalOff'
							WHEN 'KeyOnDigitalOff' THEN 'KeyOnDigitalOn'
							WHEN 'KeyOnDigitalOn' THEN 'KeyOnDigitalOff'
						END
				   END
FROM @results_pre rp
INNER JOIN @results r ON rp.VehicleId = r.VehicleId AND rp.UtilisationType = r.UtilisationType AND r.StartTime < rp.EventTime	   
WHERE rp.RowNum = 1

-- Update the Duration
UPDATE @results_pre
SET Duration = DATEDIFF(ss, [@results_pre].EventTime, ISNULL(rp2.EventTime,@e_date))
FROM @results_pre
LEFT JOIN @results_pre rp2 ON [@results_pre].VehicleId = rp2.VehicleId AND [@results_pre].Rownum + 1 = rp2.RowNum

DECLARE @subtotals TABLE (
		VehicleId UNIQUEIDENTIFIER,
		Registration NVARCHAR(MAX),
		UtilisationType NVARCHAR(20),
		TotalTime INT)

INSERT INTO @subtotals
        ( VehicleId ,
          Registration ,
          UtilisationType ,
          TotalTime
        ) 
SELECT VehicleId, Registration, CombinedType, SUM(Duration) AS TotalTime
FROM @results_pre
GROUP BY VehicleId, Registration, CombinedType
ORDER BY Registration

SELECT	k0d0.VehicleId, 
		k0d0.Registration, 

		k1d0.TotalTime AS RedTime, 
		k1d1.TotalTime AS GreenTime, 
		k0d0.TotalTime + k0d1.TotalTime AS BlueTime 
FROM @subtotals k0d0
LEFT JOIN @subtotals k1d0 ON k0d0.VehicleId = k1d0.VehicleId AND k1d0.UtilisationType = 'KeyOnDigitalOff'
LEFT JOIN @subtotals k1d1 ON k0d0.VehicleId = k1d1.VehicleId AND k1d1.UtilisationType = 'KeyOnDigitalOn'
LEFT JOIN @subtotals k0d1 ON k0d0.VehicleId = k0d1.VehicleId AND k0d1.UtilisationType = 'KeyOffDigitalOn'
WHERE k0d0.UtilisationType = 'KeyOffDigitalOff'



GO
