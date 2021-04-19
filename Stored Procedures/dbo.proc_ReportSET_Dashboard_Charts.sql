SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportSET_Dashboard_Charts]
(
	@uid UNIQUEIDENTIFIER,
	@rprtcfgid UNIQUEIDENTIFIER,
	@period INT
) 
AS

--DECLARE	@uid UNIQUEIDENTIFIER,
--		@rprtcfgid UNIQUEIDENTIFIER,
--		@period INT

--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET @rprtcfgid = N'E671E529-196F-4C6A-83FE-5F51B1257862'
--SET @period = 3

DECLARE @luid UNIQUEIDENTIFIER,
		@lrprtcfgid UNIQUEIDENTIFIER,
		@lperiod INT

SET @luid = @uid
SET @lrprtcfgid = @rprtcfgid
SET @lperiod = @period

DECLARE	@distmult FLOAT,
		@tempmult FLOAT,
		@liquidmult FLOAT,
		@co2mult FLOAT,
		@now DATETIME

SELECT @distmult = [dbo].UserPref(@luid, 202)
SELECT @tempmult = ISNULL(dbo.[UserPref](@luid, 214),1)
SELECT @liquidmult = ISNULL(dbo.[UserPref](@luid, 200),1)
SELECT @co2mult = ISNULL(dbo.UserPref(@luid, 210),1)

DECLARE @sdate DATETIME
DECLARE @edate DATETIME
SET @now = GETUTCDATE()
SET @edate = @now
-- Set start date by going back required number of months
SET @sdate = DATEADD(month, CASE @lperiod WHEN 1 THEN -2 WHEN 2 THEN -5 WHEN 3 THEN -11 END, @edate)
-- Now ensure start date is set to first of the month at 00:00
SET @sdate = CAST(FLOOR(CAST(DATEADD(dd, (DATEPART(dd, @now) * -1) + 1, @sdate) AS FLOAT)) AS DATETIME)

DECLARE @Results TABLE (
	PeriodMonth TINYINT,
	Safety FLOAT,
	Efficiency FLOAT,
	Temperature FLOAT)
	
DECLARE @Groups TABLE (
	GroupTypeId INT,
	GroupId UNIQUEIDENTIFIER)
	
DECLARE @Vehicles TABLE (
	VehicleId UNIQUEIDENTIFIER,
	VehicleIntId INT,
	Registration NVARCHAR(MAX))
	
DECLARE @Drivers TABLE (
	DriverId UNIQUEIDENTIFIER,
	DriverIntId INT)
	
DECLARE @lperiods TABLE (
	PeriodNum TINYINT,
	PeriodMonth TINYINT,
	PeriodDate DATETIME)

IF @lperiod = 3
BEGIN
	INSERT INTO @lperiods(PeriodNum, PeriodMonth, PeriodDate) VALUES (7,  DATEPART(MONTH, DATEADD(MONTH, -6, @now)), DATEADD(MONTH, -6, @now))
	INSERT INTO @lperiods(PeriodNum, PeriodMonth, PeriodDate) VALUES (8,  DATEPART(MONTH, DATEADD(MONTH, -7, @now)), DATEADD(MONTH, -7, @now))
	INSERT INTO @lperiods(PeriodNum, PeriodMonth, PeriodDate) VALUES (9,  DATEPART(MONTH, DATEADD(MONTH, -8, @now)), DATEADD(MONTH, -8, @now))
	INSERT INTO @lperiods(PeriodNum, PeriodMonth, PeriodDate) VALUES (10,  DATEPART(MONTH, DATEADD(MONTH, -9, @now)), DATEADD(MONTH, -9, @now))
	INSERT INTO @lperiods(PeriodNum, PeriodMonth, PeriodDate) VALUES (11,  DATEPART(MONTH, DATEADD(MONTH, -10, @now)), DATEADD(MONTH, -10, @now))
	INSERT INTO @lperiods(PeriodNum, PeriodMonth, PeriodDate) VALUES (12,  DATEPART(MONTH, DATEADD(MONTH, -11, @now)), DATEADD(MONTH, -11, @now))
END

IF @lperiod >= 2
BEGIN
	INSERT INTO @lperiods(PeriodNum, PeriodMonth, PeriodDate) VALUES (4,  DATEPART(MONTH, DATEADD(MONTH, -3, @now)), DATEADD(MONTH, -3, @now))
	INSERT INTO @lperiods(PeriodNum, PeriodMonth, PeriodDate) VALUES (5,  DATEPART(MONTH, DATEADD(MONTH, -4, @now)), DATEADD(MONTH, -4, @now))
	INSERT INTO @lperiods(PeriodNum, PeriodMonth, PeriodDate) VALUES (6,  DATEPART(MONTH, DATEADD(MONTH, -5, @now)), DATEADD(MONTH, -5, @now))
END

IF @lperiod >= 1
BEGIN
	INSERT INTO @lperiods(PeriodNum, PeriodMonth, PeriodDate) VALUES (1, DATEPART(MONTH, @now), @now)
	INSERT INTO @lperiods(PeriodNum, PeriodMonth, PeriodDate) VALUES (2, DATEPART(MONTH, DATEADD(MONTH, -1, @now)), DATEADD(MONTH, -1, @now))
	INSERT INTO @lperiods(PeriodNum, PeriodMonth, PeriodDate) VALUES (3, DATEPART(MONTH, DATEADD(MONTH, -2, @now)), DATEADD(MONTH, -2, @now))
END

-- Determine the groups for this user
INSERT INTO @Groups
SELECT g.GroupTypeId, g.GroupId
FROM dbo.UserGroup ug
INNER JOIN dbo.[Group] g ON ug.GroupId = g.GroupId
WHERE ug.UserId = @luid
  AND g.GroupTypeId IN (1,2) -- vehicle and driver groups
  AND g.Archived = 0
  AND g.IsParameter = 0 

INSERT INTO @Vehicles
        ( VehicleId, VehicleIntId, Registration )
SELECT v.Vehicleid, v.VehicleIntId, v.Registration
FROM dbo.Vehicle v
INNER JOIN GroupDetail gd ON gd.EntityDataId = v.VehicleId
INNER JOIN @Groups g ON gd.GroupId = g.GroupId
WHERE v.Archived = 0
  
INSERT INTO @Drivers
		( Driverid, DriverintId )
SELECT DISTINCT d.DriverId, d.DriverIntId
FROM dbo.Driver d
INNER JOIN dbo.GroupDetail gd ON d.DriverId = gd.EntityDataId
INNER JOIN @Groups g ON gd.GroupId = g.GroupId
WHERE d.Archived = 0
  AND d.Number != 'No ID'

DECLARE @data TABLE (PeriodMonth INT, PeriodStartDate DATETIME, PeriodEnddate DATETIME, Efficiency FLOAT, Safety FLOAT)

-- Create string of driver group ids to use as parameter
DECLARE @gids NVARCHAR(MAX)
SELECT @gids = COALESCE(@gids + ',', '') + CAST(GroupId AS NVARCHAR(MAX))
FROM @Groups
WHERE GroupTypeId = 2

INSERT INTO @data
EXEC dbo.proc_ReportByVehicleConfigId_SETDashboardGraphs @gids = @gids, -- varchar(max)
    @sdate = NULL, -- datetime
    @edate = NULL, -- datetime
    @uid = @luid, -- uniqueidentifier
    @rprtcfgid = @lrprtcfgid, -- uniqueidentifier
    @periodType = @lperiod -- int

----Calculate Safety and Efficiency by DRIVER
INSERT INTO @Results
        (PeriodMonth, Safety, Efficiency)
SELECT PeriodMonth, Safety, Efficiency
FROM @data d

--Calculate Temperature by VEHICLE
UPDATE @Results
SET Temperature = t.Temperature
FROM @Results r
INNER JOIN 

(
	SELECT	p.PeriodMonth, 100 - (CAST(OverTempDuration AS FLOAT) / CAST(CASE WHEN OutsideDuration > 0 THEN OutsideDuration ELSE NULL END AS FLOAT) * 100) AS Temperature
	FROM 
			(SELECT
				p.PeriodMonth,
				ISNULL(SUM(r.OverLimitDuration),0) AS OverTempDuration,
				ISNULL(SUM(r.OutsideDuration), 0) AS OutsideDuration
					
			FROM 	dbo.ReportingNCE r
				INNER JOIN @lperiods p ON DATEPART(MONTH, r.date) = p.PeriodMonth
				INNER JOIN @Vehicles v ON v.VehicleIntId = r.VehicleIntId
				
			WHERE r.Date BETWEEN @sdate AND @edate
			GROUP BY p.PeriodMonth
			) data
	RIGHT JOIN @lperiods p ON data.PeriodMonth = p.PeriodMonth
) t ON r.PeriodMonth = t.PeriodMonth

SELECT 'Type' = CASE WHEN i.IndicatorId = 14 THEN 'Efficiency' WHEN i.IndicatorId = 15 THEN 'Safety' WHEN i.IndicatorId = 27 THEN 'Temperature' END,
	   PeriodDate,
	   'Value' = CASE WHEN i.IndicatorId = 14 THEN Efficiency WHEN i.IndicatorId = 15 THEN Safety WHEN i.IndicatorId = 27 THEN Temperature END
FROM @Results r
CROSS JOIN dbo.ReportConfiguration rc
INNER JOIN dbo.IndicatorConfig ic ON rc.ReportConfigurationId = ic.ReportConfigurationId
INNER JOIN dbo.Indicator i ON ic.IndicatorId = i.IndicatorId
RIGHT JOIN @lperiods p ON r.PeriodMonth = p.PeriodMonth
WHERE ic.ReportConfigurationId = @lrprtcfgid
  AND i.IndicatorId IN (14,15,27) -- Efficiency, Safety, Temperature
  AND ic.Archived = 0
  AND i.Archived = 0
ORDER BY 'Type', p.PeriodNum DESC



		

GO
