SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_UnitInfo_UpdateOnUpgrade]
(
	@VehicleId nchar(10),
	@UpgradeLevel INT = NULL,
	@UpgradeID INT = NULL,
	@UpgradePos INT = NULL,
	@UpgradeFile INT = NULL,
	@UpgradeSectors INT = NULL
)
AS
BEGIN
	
	UPDATE dbo.UnitInfo
	SET UpgradeLevel =	 CASE WHEN @UpgradeLevel IS NULL	THEN UpgradeLevel	ELSE @UpgradeLevel END,
		UpgradeID =		 CASE WHEN @UpgradeID IS NULL		THEN UpgradeID		ELSE @UpgradeID END,
		UpgradePos =	 CASE WHEN @UpgradePos IS NULL		THEN UpgradePos		ELSE @UpgradePos END,
		UpgradeFile =	 CASE WHEN @UpgradeFile IS NULL		THEN UpgradeFile	ELSE @UpgradeFile END,
		UpgradeSectors = CASE WHEN @UpgradeSectors IS NULL	THEN UpgradeSectors	ELSE @UpgradeSectors END
	WHERE VehicleId = @VehicleId
	
END




GO
