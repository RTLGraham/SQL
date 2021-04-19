SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_AuditCameraBySerial] 
	@serial NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	--DECLARE @serial NVARCHAR(MAX)
	--SET @serial = '22400021'

	SELECT TOP 1 
		ISNULL(cust.Name, cs.Name) AS Customer, 
		ISNULL(v.Registration, 'Stock ' + cam.Serial) AS Registration, 
		cam.Serial,
		v.VehicleId,
		vle.EventDateTime,
		i.TrackerNumber
	FROM dbo.Camera cam
		LEFT OUTER JOIN dbo.CustomerCameraStock ccs ON ccs.CameraId = cam.CameraId
		LEFT OUTER JOIN dbo.Customer cs ON cs.CustomerId = ccs.CustomerId
		LEFT OUTER JOIN dbo.VehicleCamera vc ON vc.CameraId = cam.CameraId AND vc.Archived = 0 AND vc.EndDate IS NULL 
		LEFT OUTER JOIN dbo.Vehicle v ON v.VehicleId = vc.VehicleId AND v.Archived = 0 
		LEFT OUTER JOIN dbo.IVH i ON i.IVHId = v.IVHId
		LEFT OUTER JOIN dbo.VehicleLatestAllEvent vle ON vle.VehicleId = v.VehicleId
		LEFT OUTER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId AND cv.Archived = 0 
		LEFT OUTER JOIN dbo.Customer cust ON cust.CustomerId = cv.CustomerId AND cust.Archived = 0 
	WHERE cam.Serial = @serial AND cam.Archived = 0
	ORDER BY cust.Name DESC, v.Registration DESC

END
GO
