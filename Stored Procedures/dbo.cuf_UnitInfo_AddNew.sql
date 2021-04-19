SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[cuf_UnitInfo_AddNew]
(
	@VehicleId nchar(10),
	@LastComs NVARCHAR(20) = NULL,
	@JobsRead int = NULL,
	@UnitTime nvarchar(20) = NULL,
	@EconoSpeed bit = NULL,
	@SDcard bit = NULL,
	@Firmware nchar(10) = NULL,
	@UpgradeLevel int = NULL,
	@UpgradeID int = NULL,
	@UpgradePos int = NULL,
	@UpgradeFile int = NULL,
	@UpgradeSectors int = NULL
)
AS
BEGIN
	
	INSERT INTO dbo.UnitInfo
	        ( VehicleId ,
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
	        )
	VALUES  ( @VehicleId , -- VehicleId - nchar(10)
	          @LastComs , -- LastComs - nvarchar(20)
	          @JobsRead , -- JobsRead - int
	          @UnitTime , -- UnitTime - nvarchar(20)
	          @EconoSpeed , -- EconoSpeed - bit
	          @SDcard , -- SDcard - bit
	          @Firmware , -- Firmware - nchar(10)
	          @UpgradeLevel , -- UpgradeLevel - int
	          @UpgradeID , -- UpgradeID - int
	          @UpgradePos , -- UpgradePos - int
	          @UpgradeFile , -- UpgradeFile - int
	          @UpgradeSectors  -- UpgradeSectors - int
	        )
	
END





GO
