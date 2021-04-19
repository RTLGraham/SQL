SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ReportFuelDashboard]
	(
		@gids VARCHAR(MAX),
		@sdate DATETIME,
		@edate DATETIME,
		@uid UNIQUEIDENTIFIER,
        @fuelunitcode CHAR(1) = 'L'
	)
AS
BEGIN
	SET NOCOUNT ON;
    
	--DECLARE	@gids VARCHAR(MAX),
	--	@sdate DATETIME,
	--	@edate DATETIME,
	--	@uid UNIQUEIDENTIFIER;

	--SET @gids = NULL;
	--SET @sdate = '2011-09-01 00:00:00';
	--SET @edate = '2011-12-31 23:59:59';
	--SET @uid = N'38AAFFD4-1AE7-479B-889A-4D7F52C0DB58';

--Spare Terminal: remove

DECLARE @lgids varchar(max),
		@lsdate datetime,
		@ledate datetime,
		@luid UNIQUEIDENTIFIER,
		@lfuelunitcode CHAR(1)

SET @lgids = @gids
SET @lsdate = @sdate
SET @ledate = @edate
SET @luid = @uid
SET @lfuelunitcode = @fuelunitcode



	DECLARE	@fuelstr VARCHAR(20),
		@fuelmult FLOAT;

	SELECT	@fuelstr = CASE @lfuelunitcode
                                        WHEN 'K' THEN 'KPL'
                                        WHEN 'M' THEN 'mpg'
                                        ELSE 'l/100km'
                                END,
		@fuelmult = CASE @lfuelunitcode
                                        WHEN 'K' THEN 0.001    --km/l
                                        WHEN 'M' THEN 0.002825 --mpg
                                        ELSE 0.1               --l/100km
                               END,
		@lsdate = [dbo].TZ_ToUTC(@lsdate, DEFAULT, @luid),
		@ledate = [dbo].TZ_ToUTC(@ledate, DEFAULT, @luid),
		@lgids = NULLIF(@lgids,'');

	WITH	RawData AS (
		SELECT	g.GroupName,
			CONVERT(NCHAR(4), DATEPART(YY, r.Date)) + '-' + RIGHT('0' + CONVERT(NVARCHAR(2), DATEPART(MM, r.Date)), 2) AS [Month],
			DrivingDistance + PTOMovingDistance AS DrivingDistance,
			TotalFuel,
			FuelMultiplier
		FROM	dbo.Reporting r
			INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
			INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
			INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
		WHERE	r.Date BETWEEN @lsdate AND @ledate 
		AND	(@lgids IS NULL OR g.GroupId IN (SELECT Value FROM dbo.Split(@lgids, ',')))
		AND	g.GroupId IN (SELECT ug.GroupId 
						  FROM dbo.UserGroup ug
							INNER JOIN dbo.[Group] g ON ug.GroupId = g.GroupId
						  WHERE UserId = @luid AND g.GroupName NOT LIKE '%Spare%Terminal%'
								AND g.IsParameter = 0 AND g.Archived = 0 AND g.GroupTypeId = 1)
		AND	g.IsParameter = 0
		AND	g.Archived = 0
		AND	g.GroupTypeId = 1)
	SELECT	COALESCE(GroupName, N'Total') AS GroupName,
		COALESCE([Month], N'YTD') AS [Month],
		(CASE
			WHEN @fuelmult = 0.1 THEN
				(CASE WHEN SUM(TotalFuel) = 0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier, 1.0)) * 100 END)
				/ SUM(DrivingDistance) 
			ELSE
				(SUM(DrivingDistance) * 1000)
				/ (CASE WHEN SUM(TotalFuel)=0 THEN NULL ELSE SUM(TotalFuel * ISNULL(FuelMultiplier,1.0)) END) * @fuelmult
		END) AS FuelEcon,
		@fuelstr AS FuelStr
	FROM	RawData
	GROUP BY	GroupName, [Month] WITH CUBE
	HAVING	SUM(DrivingDistance) > 10 AND SUM(TotalFuel) <> 0
	ORDER BY	GroupName, [Month];
END;

GO
