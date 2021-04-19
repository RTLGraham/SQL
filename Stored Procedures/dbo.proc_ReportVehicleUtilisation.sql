SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_ReportVehicleUtilisation]
(
	@vids NVARCHAR(MAX) = NULL, 
	@sdate DATETIME = NULL, 
	@edate DATETIME = NULL,
    @uid UNIQUEIDENTIFIER = NULL
)
AS

--DECLARE	@vids NVARCHAR(MAX),
--		@sdate DATETIME,
--		@edate DATETIME,
--		@uid UNIQUEIDENTIFIER
		
--SET @vids = N'0bc13952-f7b0-4a6f-9d60-cb6a456ceb48,462ed6b8-5c4f-4ba8-9ba8-fb5e7f53c52c'
--SET @sdate = '2019-06-01 00:00'
--SET @edate = '2019-06-20 23:59'
--SET @uid = N'988d25de-65e9-4fc5-8981-3d2b4ea0feab'

/****************************************************************************************************/
/*                                Vehicle Utilisation Report                                        */
/*                                --------------------------                                        */
/* This report calculates durations of Drive, Idle, PTO and KeyOff to determine the utilisation		*/
/* percentage of each vehicle during a given period. A total for all vehicles is also provided.		*/
/*											                                                        */
/****************************************************************************************************/

SET @sdate = [dbo].TZ_ToUTC(@sdate,default,@uid)
SET @edate = [dbo].TZ_ToUTC(@edate,default,@uid);

--First way


WITH Utilistation_CTE (VehicleId,Registration, VehicleModeId, Duration)
AS	
(
	SELECT v.VehicleId,v.Registration, vma.VehicleModeID AS VehicleModeId, SUM(DATEDIFF(SECOND, vma.StartDate, vma.EndDate)) AS Duration
	FROM dbo.VehicleModeActivity vma
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = vma.VehicleIntId
	WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
	  AND vma.StartDate BETWEEN @sdate AND @edate
	GROUP BY v.VehicleId,v.Registration, vma.VehicleModeID WITH CUBE
	
)
--SELECT * FROM Utilistation_CTE




SELECT Registration,VehicleId,[1] AS DriveDuration,[2] AS IdleDuration,[3] AS KeyOnDuration,[4] AS KeyOffDuration,[5] AS PtoDuration --u.VehicleId, vm.Name AS VehicleMode, u.VehicleModeId, u.Duration
FROM (SELECT Registration,VehicleId,VehicleModeId,Duration
		FROM Utilistation_CTE
		WHERE VehicleId IS NOT NULL AND Registration IS NOT NULL) src
PIVOT(
	AVG(Duration)
	for VehicleModeId in ([1],[2],[3],[4],[5]) --Drive,Idle,KeyOn,KeyOff,Pto
) piv

--Second way

--WITH Utilistation_CTE (VehicleId, VehicleModeId, Duration)
--AS	
--(
--	SELECT v.VehicleId, vma.VehicleModeID AS VehicleModeId, SUM(DATEDIFF(SECOND, vma.StartDate, vma.EndDate)) AS Duration
--	FROM dbo.VehicleModeActivity vma
--	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = vma.VehicleIntId
--	WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
--	  AND vma.StartDate BETWEEN @sdate AND @edate
--	GROUP BY v.VehicleId, vma.VehicleModeID WITH CUBE
--)

--SELECT v.Registration, u.VehicleId, vm.Name AS VehicleMode, u.VehicleModeId, u.Duration
--FROM Utilistation_CTE u
--LEFT JOIN dbo.Vehicle v ON v.VehicleId = u.VehicleId
--INNER JOIN dbo.VehicleMode vm ON vm.VehicleModeID = u.VehicleModeId
--ORDER BY v.Registration, u.VehicleModeID

--Third  way

--WITH Utilistation_CTE (VehicleId, VehicleModeId, Duration)
--AS	
--(
--	SELECT v.VehicleId, vma.VehicleModeID AS VehicleModeId, SUM(DATEDIFF(SECOND, vma.StartDate, vma.EndDate)) AS Duration
--	FROM dbo.VehicleModeActivity vma
--	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = vma.VehicleIntId
--	WHERE v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
--	  AND vma.StartDate BETWEEN @sdate AND @edate
--	GROUP BY v.VehicleId, vma.VehicleModeID WITH CUBE
--)
--SELECT
--	v.Registration
--   ,u.VehicleId
--   ,u.Duration AS DriveDuration
--   ,idle.Duration AS IdleDuration
--   ,keyon.Duration AS KeyOnDuration
--   ,keyoff.Duration AS KeyOffDuration
--   ,pto.Duration AS PtoDuration
--FROM Utilistation_CTE u
--LEFT JOIN dbo.Vehicle v
--	ON v.VehicleId = u.VehicleId
--LEFT JOIN (SELECT
--		U.Duration
--	   ,U.VehicleId
--	FROM Utilistation_CTE U
--	WHERE U.VehicleModeId = 2) idle ON idle.VehicleId = u.VehicleId
--LEFT JOIN (SELECT
--		U.Duration
--	   ,U.VehicleId
--	FROM Utilistation_CTE U
--	WHERE U.VehicleModeId = 3) keyon ON keyon.VehicleId = u.VehicleId
--LEFT JOIN (SELECT
--		U.Duration
--	   ,U.VehicleId
--	FROM Utilistation_CTE U
--	WHERE U.VehicleModeId = 4) keyoff ON keyoff.VehicleId = u.VehicleId
--LEFT JOIN (SELECT
--		U.Duration
--	   ,U.VehicleId
--	FROM Utilistation_CTE U
--	WHERE U.VehicleModeId = 5) pto ON pto.VehicleId = u.VehicleId
--WHERE u.VehicleModeId = 1 AND u.VehicleId IS NOT NULL
--ORDER BY v.Registration, u.VehicleModeId


GO
