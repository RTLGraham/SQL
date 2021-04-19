SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Driver_GetLinkedVehicle]
(
	@userId UNIQUEIDENTIFIER,
	@driverId UNIQUEIDENTIFIER
)
AS
	--DECLARE @driverId UNIQUEIDENTIFIER
	--SET @driverId = N'26658162-5EAA-4BFC-1111-14C13604377A'
	
	SELECT v.VehicleId, v.Registration
	FROM dbo.Vehicle v
		INNER JOIN dbo.VehicleDriver vd ON vd.VehicleId = v.VehicleId 
	WHERE v.Archived = 0 AND vd.EndDate IS NULL AND vd.Archived = 0
		AND vd.DriverId = @driverId
	ORDER BY v.Registration

GO
