SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_GetMaintenanceFaults]
(
	@vid UNIQUEIDENTIFIER = NULL,
	@sdate DATETIME = NULL,
	@edate DATETIME = NULL
)
AS

--DECLARE @vid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME

--SET @vid = NULL --N'A2A7640A-7CD1-48D3-8270-80A8F2C9FA63'
--SET @sdate = NULL
--SET @edate = NULL


IF @sdate IS NULL SET @sdate = '1900-01-01'
IF @edate IS NULL SET @edate = '2999-12-31'

DECLARE @groupnames TABLE
(
	VehicleId UNIQUEIDENTIFIER,
	GroupNames VARCHAR(MAX)
)

DECLARE @groupname VARCHAR(1024)

INSERT INTO @groupnames (VehicleId, GroupNames)
SELECT v.VehicleId, 
	 STUFF((SELECT '; ' + g.GroupName
	 FROM dbo.GroupDetail gd
	 INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId AND g.GroupTypeId = 1 AND g.IsParameter = 0 AND g.Archived = 0
	 WHERE gd.EntityDataId = v.VehicleId
	 FOR XML PATH('')), 1, 1, '') [GroupNames]
FROM dbo.Vehicle v
WHERE v.VehicleId = @vid OR @vid IS NULL
GROUP BY v.VehicleId

DECLARE @results TABLE
(
	DatabaseName NVARCHAR(250),
	MaintenanceJobId INT,
	MaintenanceFaultId INT,
	CustomerId UNIQUEIDENTIFIER,
	CustomerName NVARCHAR(250),
	VehicleId UNIQUEIDENTIFIER,
	Registration NVARCHAR(250),
	VehicleTypeId INT,
	GroupNames NVARCHAR(MAX),
	IVHId UNIQUEIDENTIFIER,
	TrackerType NVARCHAR(100),
	TrackerNumber NVARCHAR(50),
	CreationDateTime DATETIME,
	EngineerDateTime DATETIME NULL,
	Engineer NVARCHAR(100) NULL,
	SupportTicketId INT NULL,
	FaultTypeId SMALLINT,
	FaultType NVARCHAR(100),
	FaultDateTime DATETIME NULL,
	AssetTypeId SMALLINT NULL,
	AssetType NVARCHAR(254) NULL,
	AssetReference NVARCHAR(100) NULL,
	AcknowledgedBy NVARCHAR(250) NULL,
	ResolvedDate DATETIME NULL,
	AssignedGroupId UNIQUEIDENTIFIER NULL,
	AssignedUserId UNIQUEIDENTIFIER NULL,
	ActiveFirmwareBuild NVARCHAR(MAX)
)

INSERT INTO @results
        ( DatabaseName ,
          MaintenanceJobId ,
          MaintenanceFaultId ,
          CustomerId ,
          CustomerName ,
          VehicleId ,
          Registration ,
          VehicleTypeId ,
          GroupNames ,
          IVHId ,
          TrackerType ,
		  TrackerNumber,
          CreationDateTime ,
          EngineerDateTime ,
          Engineer ,
          SupportTicketId ,
          FaultTypeId ,
          FaultType ,
		  FaultDateTime ,
          AssetTypeId ,
          AssetType ,
          AssetReference ,
          AcknowledgedBy ,
          ResolvedDate ,
		  AssignedGroupId ,
		  AssignedUserId,
		  ActiveFirmwareBuild
        )
SELECT	'NG_Fleetwise' AS DatabaseName,
		mj.MaintenanceJobId,
		mf.MaintenanceFaultId,
		c.CustomerId,
		c.Name AS CustomerName,
		v.VehicleId,
		v.Registration,
		v.VehicleTypeId,
		gn.GroupNames, --dbo.GetVehicleGroupNamesByVehicle(v.VehicleId) AS GroupNames,
		i.IVHId,
		it.Name AS TrackerType,
		i.TrackerNumber,
		mj.CreationDateTime,
		mj.EngineerDateTime,
		mj.Engineer,
		mj.SupportTicketId,
		mf.FaultTypeId,
		mft.Name AS FaultType,
		mf.FaultDateTime,
		mf.AssetTypeId,
		mat.Name AS AssetType,
		mf.AssetReference,
		u.FirstName AS AcknowledgedBy,
		ResolvedDateTime,
		mj.AssignedGroupId,
		mj.AssignedUserId,
		vf.Website + '_' + vf.Network + '_' + vf.Com1 + '_' + vf.Com2 + '_' + vf.CanType + CASE WHEN vf.Options IS NULL THEN '' ELSE '_' + vf.Options END + '_' + vf.[Version]
FROM dbo.MaintenanceJob mj
INNER JOIN dbo.Vehicle v ON v.VehicleIntId = mj.VehicleIntId
INNER JOIN @groupnames gn ON gn.VehicleId = v.VehicleId
INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
INNER JOIN dbo.IVH i ON i.IVHId = v.IVHId
INNER JOIN dbo.IVHType it ON it.IVHTypeId = i.IVHTypeId
INNER JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId
INNER JOIN dbo.MaintenanceFaultType mft ON mft.FaultTypeId = mf.FaultTypeId
LEFT JOIN dbo.MaintenanceAssetType mat ON mat.AssetTypeId = mf.AssetTypeId
LEFT JOIN dbo.[User] u ON mf.AcknowledgedBy = u.UserID
LEFT JOIN dbo.VehicleFirmware vf ON vf.VehicleId = v.VehicleId AND vf.BaseActiveInd = 'A'
WHERE (v.VehicleId = @vid OR @vid IS NULL)
  AND cv.EndDate IS NULL	
  AND (mj.ResolvedDateTime IS NULL OR @vid IS NOT NULL)
  AND mj.CreationDateTime BETWEEN @sdate AND @edate
  AND mj.Archived = 0
  AND mf.Archived = 0
  AND cv.Archived = 0
  AND mft.FaultTypeId NOT IN 
	(
		21, --SS1
		14	--DataDelay
	)
  --AND c.Name IN ('Nestle Switzerland', 'Nestle Germany OOH', 'Nestle Germany RML', 'Nestle Germany SLKW')

SELECT DatabaseName ,
       MaintenanceJobId ,
       MaintenanceFaultId ,
       CustomerId ,
       CustomerName ,
       VehicleId ,
       Registration ,
       VehicleTypeId ,
       GroupNames ,
       IVHId ,
       TrackerType ,
	   TrackerNumber ,
       CreationDateTime ,
       EngineerDateTime ,
       Engineer ,
       SupportTicketId ,
       FaultTypeId ,
       FaultType ,
	   FaultDateTime ,
       AssetTypeId ,
       AssetType ,
       AssetReference ,
       AcknowledgedBy ,
       ResolvedDate,
	   AssignedGroupId,
	   AssignedUserId,
	   ActiveFirmwareBuild
FROM @results
where registration is not NULL
order by CustomerName, Registration


	

GO
