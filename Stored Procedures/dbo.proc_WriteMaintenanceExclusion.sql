SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_WriteMaintenanceExclusion]
(
	@vid UNIQUEIDENTIFIER,
	@faultTypeId SMALLINT,
	@excludeUntil DATETIME NULL
)
AS
BEGIN

	--DECLARE	@vid UNIQUEIDENTIFIER,
	--		@faultTypeId SMALLINT,
	--		@excludeUntil DATETIME

	--SET @vid = N'5F3CEA35-DCBE-4120-9301-09FF638BF9DF'
	--SET @faultTypeId = 0
	--SET @excludeUntil = NULL

	DECLARE @result INT

	-- Write Maintenance Exclusion record
	INSERT INTO dbo.MaintenanceExclusion
	        ( VehicleIntId ,
	          FaultTypeId ,
			  ExcludeUntil ,
	          Archived ,
	          LastOperation
	        )
	SELECT VehicleIntId, @faultTypeId, @excludeUntil, 0, GETDATE()
	FROM dbo.Vehicle
	WHERE VehicleId = @vid

	SET @result = SCOPE_IDENTITY()

	-- Now delete any excluded faults from open jobs
	DELETE	
	FROM dbo.MaintenanceFault
	FROM dbo.MaintenanceFault mf
	INNER JOIN dbo.MaintenanceJob mj ON mj.MaintenanceJobId = mf.MaintenanceJobId
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = mj.VehicleIntId
	WHERE v.VehicleId = @vid
	  AND (mf.FaultTypeId = @faultTypeId OR @faultTypeId = 0)
	  AND mj.ResolvedDateTime IS NULL

	-- If this leaves any orphaned MaintenanceJob records - delete these too
	DELETE	
	FROM dbo.MaintenanceJob
	FROM dbo.MaintenanceJob mj
	INNER JOIN dbo.Vehicle v ON v.VehicleIntId = mj.VehicleIntId
	LEFT JOIN dbo.MaintenanceFault mf ON mf.MaintenanceJobId = mj.MaintenanceJobId
	WHERE v.VehicleId = @vid
	  AND mf.MaintenanceFaultId IS NULL	
	  AND mj.ResolvedDateTime IS NULL	

	SELECT @result

END







GO
