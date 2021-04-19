SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_Report_ProactiveMaintenance]
(
	@uid UNIQUEIDENTIFIER,
	@vids NVARCHAR(MAX) = NULL,
	@sdate DATETIME = NULL,
	@edate DATETIME = NULL
)
AS

	--DECLARE @uid UNIQUEIDENTIFIER,
	--		@vids NVARCHAR(MAX),
	--		@sdate DATETIME,
	--		@edate DATETIME

	--SET @vids = N'3B44462B-97C1-42D1-BDF5-20E099536EA8' --N'0F5FE526-4BE0-42BD-8A52-8C76CE85D9BE'
	--SET @sdate = NULL
	--SET @edate = NULL
	--SET @uid = N'AC5FC459-FAF5-48D7-BBBE-88CC5EE824E1'


	IF @sdate IS NULL SET @sdate = '1900-01-01'
	IF @edate IS NULL SET @edate = '2999-12-31'

	DECLARE @groupnames TABLE
	(
		VehicleId UNIQUEIDENTIFIER,
		GroupNames VARCHAR(1024)
	)

	DECLARE @groupname VARCHAR(1024)

	INSERT INTO @groupnames (VehicleId, GroupNames)
	SELECT v.VehicleId, 
		 STUFF((SELECT '; ' + g.GroupName
				 FROM dbo.GroupDetail gd
				 INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId AND g.GroupTypeId = 1 AND g.IsParameter = 0 AND g.Archived = 0
				 INNER JOIN dbo.UserGroup ug ON ug.GroupId = g.GroupId
				 WHERE gd.EntityDataId = v.VehicleId AND ug.UserId = @uid
		 FOR XML PATH('')), 1, 1, '') [GroupNames]
	FROM dbo.Vehicle v
		INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
		INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
		INNER JOIN dbo.UserGroup ug ON ug.GroupId = g.GroupId
	WHERE ug.UserId = @uid AND g.Archived = 0 AND g.IsParameter = 0 AND g.GroupTypeId = 1 AND v.Archived = 0 AND ug.Archived = 0
		AND (@vids IS NULL OR v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ',')))
	GROUP BY v.VehicleId


	SELECT	v.VehicleId,
			v.Registration,
			v.VehicleTypeId,
			RTRIM(LTRIM(gn.GroupNames)) AS GroupNames,
			vle.EventDateTime AS LastEventDateTime,
		
			i.IVHId,
			it.IVHTypeId AS TrackerTypeId,
			it.Name AS TrackerType,
			i.TrackerNumber,
			vf.Website + '_' + vf.Network + '_' + vf.Com1 + '_' + vf.Com2 + '_' + vf.CanType + CASE WHEN vf.Options IS NULL THEN '' ELSE '_' + vf.Options END + '_' + vf.[Version] AS TrackerActiveFirmware,
		
			cam.CameraId,
			cam.Serial AS CameraSerial,
		
			mj.MaintenanceJobId,
			mj.CreationDateTime AS ProactiveMaintenanceRecordCreationDate,
			u.UserID AS AcknowledgedByUserID,
			u.FirstName AS AcknowledgedBy,
			mj.EngineerDateTime,
			mj.Engineer,
			mj.SupportTicketId,
		
			mf.MaintenanceFaultId,
			mf.FaultTypeId,
			mft.Name AS FaultType,
			mf.FaultDateTime,
			mf.AssetTypeId,
			mat.Name AS AssetType,
			mf.AssetReference
	FROM dbo.Vehicle v
		INNER JOIN @groupnames gn ON gn.VehicleId = v.VehicleId
		INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
		LEFT JOIN dbo.VehicleLatestAllEvent vle ON vle.VehicleId = v.VehicleId
		LEFT OUTER JOIN dbo.VehicleCamera vc ON vc.VehicleId = v.VehicleId AND vc.Archived = 0 AND vc.EndDate IS NULL
		LEFT OUTER JOIN dbo.Camera cam ON cam.CameraId = vc.CameraId AND cam.Archived = 0
		LEFT JOIN dbo.IVH i ON i.IVHId = v.IVHId
		LEFT JOIN dbo.IVHType it ON it.IVHTypeId = i.IVHTypeId
		LEFT JOIN dbo.VehicleFirmware vf ON vf.VehicleId = v.VehicleId AND vf.BaseActiveInd = 'A'

		LEFT JOIN dbo.MaintenanceJob mj ON v.VehicleIntId = mj.VehicleIntId 
															AND mj.ResolvedDateTime IS NULL
															AND mj.Archived = 0
															AND mj.CreationDateTime BETWEEN @sdate AND @edate
		LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId
															--AND mf.AcknowledgedBy IS NOT NULL
															AND mf.Archived = 0
															AND mf.FaultTypeId NOT IN
															(
																--Excluded as per instruction of KR on 22/10/2018 prior to the Hoyer meeting. Further action TBC:
																14--, -- Data delay
																--30, -- SS/OR configuration
																--31, -- SS/OR configuration
																--32  -- SS/OR configuration
																--33  -- Image sensor issue
															)
		LEFT JOIN dbo.MaintenanceFaultType mft ON mft.FaultTypeId = mf.FaultTypeId
		LEFT JOIN dbo.MaintenanceAssetType mat ON mat.AssetTypeId = mf.AssetTypeId
		LEFT JOIN dbo.[User] u ON mf.AcknowledgedBy = u.UserID
	WHERE 
		cv.EndDate IS NULL	
		AND cv.Archived = 0

	ORDER BY mf.MaintenanceFaultId DESC, v.Registration

GO
