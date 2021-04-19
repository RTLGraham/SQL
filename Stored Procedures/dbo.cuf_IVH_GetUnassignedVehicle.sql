SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_IVH_GetUnassignedVehicle]
AS
	SELECT i.IVHId, v.VehicleId, i.TrackerNumber, i.LastOperation AS InstallDate
	FROM [dbo].[IVH] i
	INNER JOIN [dbo].[Vehicle] v ON i.IVHId = v.IVHId
	INNER JOIN [dbo].CustomerVehicle cv ON v.VehicleId = cv.VehicleId AND cv.VehicleId not in 
	(
		SELECT v.VehicleId 
		FROM [dbo].[IVH] i
		INNER JOIN [dbo].[Vehicle] v ON i.IVHId = v.IVHId
		INNER JOIN [dbo].CustomerVehicle cv ON v.VehicleId = cv.VehicleId
		INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId AND c.CustomerIntId != 0
		WHERE cv.Archived = 0 AND ((cv.EndDate IS NULL) OR (cv.EndDate >= GETDATE())) AND cv.StartDate < GETDATE()
	)
	INNER JOIN dbo.Customer c ON cv.CustomerId = c.CustomerId
	WHERE cv.Archived = 0 AND ((cv.EndDate IS NULL) OR (cv.EndDate >= GETDATE())) AND cv.StartDate < GETDATE() AND c.CustomerIntId = 0

GO
