SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_IVH_GetProvisionedDetails]
(
	@customerintid int
)
AS

DECLARE @date datetime
SET @date = GETDATE()

SELECT
	@customerintid AS CustomerIntId,
	i.TrackerNumber,
	v.Registration,
	i.Manufacturer,
	i.Model,
	i.SerialNumber,
	i.SIMCardNumber,
	i.PhoneNumber,
	i.ServiceProvider,
	v.VehicleId,
	i.LastOperation AS InstallationDate,
	v.LastOperation AS LastOperation,
	i.IVHId,
	i.FirmwareVersion
FROM dbo.Vehicle v
INNER JOIN [dbo].[IVH] i ON v.IVHId = i.IVHId AND i.Archived != 1
INNER JOIN [dbo].[CustomerVehicle] cv ON cv.VehicleId = v.VehicleId AND cv.Archived != 1 AND ((cv.EndDate IS NULL) OR (cv.EndDate >= @date)) AND (cv.StartDate < @date)
INNER JOIN dbo.Customer c ON c.CustomerIntId = @customerintid
WHERE v.Archived != 1

GO
