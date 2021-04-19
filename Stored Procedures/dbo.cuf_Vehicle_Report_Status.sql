SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_Status]
(
	@uid UNIQUEIDENTIFIER
)
AS
BEGIN
	--DECLARE @uid UNIQUEIDENTIFIER
	--SET @uid = N'F119F353-330C-48C9-9A21-5DD95F279749'
	
	SELECT v.VehicleId, v.Registration, v.FleetNumber, i.TrackerNumber,
		vls.LastOperation AS LastComms,
		vls.UnitTime,
		vls.EcospeedStatus AS EconospeedStatus,
		vls.SDCardStatus,
		vls.Firmware,
		vls.LogNumber
	FROM dbo.VehicleLatestStatus vls
		INNER JOIN dbo.Vehicle v ON vls.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
	ORDER BY vls.LastOperation DESC
	
END

GO
