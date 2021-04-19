SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_Report_ActivityTraceByVehicle]
(
		@vids NVARCHAR(MAX),
		@uid UNIQUEIDENTIFIER,
		@sdate DATETIME,
		@edate DATETIME
)
AS

--DECLARE   @vids NVARCHAR(MAX),
--	@geofenceIds NVARCHAR(MAX),
--	@sdate DATETIME,
--	@edate DATETIME,
--	@uid UNIQUEIDENTIFIER;
--
--SET @vids = N'06627EAD-3154-4B24-B831-182A198D6B7C,5B8BDB4A-C7A9-46FC-98D0-19F918BFB3F7,9145435A-C603-4BC2-A9E4-5DA0047C4180,938854D3-B773-4E06-93E7-60BB16F72CE3,D0E15936-0B2D-4BA9-88D6-616C86C17311,C86E75A5-2046-41FE-9018-7E7CC38F6CA0,15390D3B-293F-4E81-A34E-8424110FB96E,D04CABBE-C0F1-4F48-A602-AFDF07E846C1,4D55B554-F67F-4621-B82B-D937CC7CFA66,367B1F6E-113C-4119-9540-E97480F79E5A'
--SET @sdate = '2014-04-22 00:00';
--SET @edate = '2014-04-22 23:59';
--SET @uid = N'49372CDA-15F0-4B5E-A531-459056566D8F';

SELECT @sdate = dbo.TZ_ToUtc(@sdate, DEFAULT, @uid)
SELECT @edate = dbo.TZ_ToUtc(@edate, DEFAULT, @uid)

DECLARE @Results TABLE
(
	VehicleIntId INT,
	VehicleModeId INT,
	StartDate DATETIME,
	EndDate DATETIME
)

INSERT INTO @Results
        ( VehicleIntId,
          VehicleModeID,
          StartDate,
          EndDate
        )
SELECT	v.VehicleIntId, 
		vma.VehicleModeId,
		vma.StartDate,
		vma.EndDate
FROM dbo.VehicleModeActivity vma
INNER JOIN dbo.Vehicle v ON vma.VehicleIntId = v.VehicleIntId
WHERE vma.StartDate >= @sdate
  AND ISNULL(vma.EndDate, GETUTCDATE()) <= @edate
  AND v.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ','))
        
INSERT INTO @Results
        ( VehicleIntId,
          VehicleModeId,
          StartDate,
          EndDate
        )
SELECT	VehicleIntId, 0, @sdate, MIN(StartDate)
FROM @Results
GROUP BY VehicleIntId   

UPDATE @Results
SET EndDate = CASE VehicleModeID
                   WHEN 4 THEN DATEADD(MINUTE, 1, StartDate)
                   ELSE CASE WHEN GETUTCDATE() < @edate THEN GETUTCDATE() ELSE @edate END
              END
WHERE EndDate IS NULL

INSERT INTO @Results
        ( VehicleIntId,
          VehicleModeId,
          StartDate,
          EndDate
        )
SELECT VehicleIntId, 0, MAX(EndDate), @edate
FROM @Results
GROUP BY VehicleIntId
HAVING MAX(EndDate) < @edate

SELECT  v.VehicleId AS VehicleID, v.Registration,
		ISNULL(v.VehicleTypeID, 2100000) AS VehicleTypeID,
		r.VehicleModeID,
		[dbo].TZ_GetTime(r.StartDate, DEFAULT, @uid) AS StartDate,
		[dbo].TZ_GetTime(r.EndDate, DEFAULT, @uid) AS EndDate,
        DATEDIFF(s, r.StartDate, r.EndDate) AS Duration
FROM @Results r
INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
WHERE DATEDIFF(s, r.StartDate, r.EndDate) > 0
ORDER BY r.VehicleIntId, StartDate

GO
