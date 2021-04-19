SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_UnitInfo_GetByVehicleId]
(
	@VehicleId nchar(10)
)
AS
BEGIN
	
	SELECT TOP 1
			  UnitInfoId ,
			  VehicleId ,
	          LastComs ,
	          JobsRead ,
	          UnitTime ,
	          EconoSpeed ,
	          SDcard ,
	          Firmware ,
	          UpgradeLevel ,
	          UpgradeID ,
	          UpgradePos ,
	          UpgradeFile ,
	          UpgradeSectors
	FROM dbo.UnitInfo
	WHERE VehicleId = @VehicleId
	ORDER BY UnitInfoId DESC
	
END




GO
