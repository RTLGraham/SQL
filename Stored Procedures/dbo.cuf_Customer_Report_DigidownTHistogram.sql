SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Customer_Report_DigidownTHistogram] 
(
	@cid UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER,
	@sdate DATETIME,
	@edate DATETIME
)
AS
	--DECLARE @cid UNIQUEIDENTIFIER,
	--		@uid UNIQUEIDENTIFIER,
	--		@sdate DATETIME,
	--		@edate DATETIME

	--/* test data */
	--SELECT	@cid = c.CustomerId,
	--		@uid = N'7A4C7369-7E93-455E-8B66-660E91AB26C5',
	--		@sdate = '2017-09-04 00:00',
	--		@edate = '2017-09-11 23:59'
	--FROM dbo.Customer c
	--WHERE c.Name = 'Hoyer'

	DECLARE @distmult FLOAT
	SELECT @distmult = dbo.UserPref(@uid, 202)

	DECLARE @data TABLE
	(
		VehicleIntId INT, 
		StartDate DATETIME, 
		EndDate DATETIME,
		DrivenDistance FLOAT,
		VUfiles INT,
		CRDfiles INT
	)
	INSERT INTO @data
			( VehicleIntId ,
			  StartDate ,
			  EndDate
			)
	SELECT v.VehicleIntId, dateRange.StartDate, dateRange.EndDate
	FROM dbo.CreateDependentDateRange(@sdate, @edate, @uid, 0, 0, 1) dateRange
		CROSS JOIN dbo.Vehicle v
		INNER JOIN dbo.VehicleFirmware vf ON vf.VehicleId = v.VehicleId
		INNER JOIN dbo.CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
	WHERE c.CustomerId = @cid
		AND v.Archived = 0 AND cv.Archived = 0 AND cv.EndDate IS NULL
		AND vf.BaseActiveInd = 'A' AND (vf.Com1 LIKE '%DIG%' OR vf.Com2 LIKE '%DIG%')

	UPDATE @data
	SET VUfiles = VU_Uploads,
		CRDfiles = CRD_Uploads
	FROM @data INNER JOIN 
	(
		SELECT	d.VehicleIntId, d.StartDate,
				COUNT(DISTINCT dtlVU.DigiDownTLogId) AS VU_Uploads,
				COUNT(DISTINCT dtlCRD.DigiDownTLogId) AS CRD_Uploads
		FROM @data d 
	
			LEFT OUTER JOIN dbo.DigiDownTLog dtlVU ON 
				dtlVU.VehicleIntId = d.VehicleIntId 
				AND dtlVU.FileTimeStamp BETWEEN d.StartDate AND d.EndDate
				AND dtlVU.Succeeded = 1
				AND dtlVU.FileName LIKE '%.vu'
			LEFT OUTER JOIN dbo.DigiDownTLog dtlCRD ON 
				dtlCRD.VehicleIntId = d.VehicleIntId 
				AND dtlCRD.FileTimeStamp BETWEEN d.StartDate AND d.EndDate
				AND dtlCRD.Succeeded = 1
				AND dtlCRD.FileName LIKE '%.crd'
		GROUP BY d.VehicleIntId, d.StartDate
		) o ON o.StartDate = [@data].StartDate AND o.VehicleIntId = [@data].VehicleIntId
	
	UPDATE @data
	SET DrivenDistance = ISNULL(o.DrivenDistance, 0)
	FROM @data INNER JOIN 
	(
		SELECT	d.VehicleIntId, d.StartDate,
				SUM(r.DrivingDistance) AS DrivenDistance
		FROM @data d 
			LEFT OUTER JOIN dbo.Reporting r ON r.VehicleIntId = d.VehicleIntId AND r.Date BETWEEN d.StartDate AND d.EndDate
		GROUP BY d.VehicleIntId, d.StartDate
		) o ON o.StartDate = [@data].StartDate AND o.VehicleIntId = [@data].VehicleIntId

	SELECT	c.CustomerId,
			c.Name AS Customer, 
			v.VehicleId,
			v.VehicleIntId,
			v.Registration, 
			v.VehicleTypeID,
			dbo.TZ_GetTime(d.StartDate, DEFAULT, @uid) AS StartDate,
			dbo.TZ_GetTime(d.EndDate, DEFAULT, @uid) AS EndDate,
			d.DrivenDistance ,
			d.VUfiles ,
			d.CRDfiles 
	FROM @data d
		INNER JOIN dbo.Vehicle v ON v.VehicleIntId = d.VehicleIntId
		INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
	ORDER BY c.Name, v.Registration, d.StartDate


GO
