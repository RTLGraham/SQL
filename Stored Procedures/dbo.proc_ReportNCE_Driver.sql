SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ReportNCE_Driver]
(
	@gid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME,
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @gid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME,
--		@uid UNIQUEIDENTIFIER
--	
--SET @gid = N'B04062C4-67FA-41A9-9BFC-4776782653B4' -- CH 0025 Rümlang
--SET @sdate = '2013-09-01 00:00'
--SET @edate = '2013-09-05 23:59'
--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

DECLARE @lgid UNIQUEIDENTIFIER,
		@lsdate DATETIME,
		@ledate DATETIME,
		@luid UNIQUEIDENTIFIER
		
SET @lgid = @gid
SET @lsdate = @sdate
SET @ledate = @edate
SET @Luid = @uid

SET @lsdate = dbo.TZ_ToUtc(@lsdate, DEFAULT, @luid)
SET @ledate = dbo.TZ_ToUtc(@ledate, DEFAULT, @luid)

DECLARE @Interim TABLE (
	DriverInd SMALLINT,
	Distance FLOAT )
	
INSERT INTO @Interim (DriverInd, Distance)
SELECT	CASE WHEN d.Number = 'No Id' THEN 0 ELSE 1 END AS DriverloggedIn,
		SUM(DrivingDistance) AS Distance
FROM dbo.Accum a
INNER JOIN dbo.Driver d ON a.DriverIntId = d.DriverIntId
INNER JOIN dbo.Vehicle v ON a.VehicleIntId = v.VehicleIntId
INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
WHERE gd.GroupId = @lgid
	AND a.CreationDateTime BETWEEN @lsdate AND @ledate
	AND a.ClosureDateTime BETWEEN @lsdate AND @ledate
GROUP BY CASE WHEN d.Number = 'No Id' THEN 0 ELSE 1 END

SELECT ISNULL(i1.Distance / CASE WHEN (i0.Distance + i1.Distance) = 0 THEN NULL ELSE (i0.Distance + i1.Distance) END, 0) AS DriverLoggedInPercent
FROM @Interim i0
INNER JOIN @Interim i1 ON i1.DriverInd = i0.DriverInd + 1 
WHERE i0.Driverind = 0

GO
