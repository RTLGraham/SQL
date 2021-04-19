SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<D. Jurins>
-- Create date: <2010/10/27>
-- Description:	<Calculates the safety score>
-- =============================================
CREATE FUNCTION [dbo].[ScoreByClassConfig]
(
	@class CHAR(1),
	@SweetSpot FLOAT,
	@OverRevWithFuel FLOAT,
	@TopGear FLOAT,
	@Cruise FLOAT,
	@CruiseInTopGears FLOAT,
	@CoastInGear FLOAT,
	@Idle FLOAT,
	@EngineServiceBrake FLOAT,
	@OverRevWithoutFuel FLOAT,
	@Rop FLOAT,
	@OverSpeed FLOAT,
	@OverSpeedHigh FLOAT,
	@CoastOutOfGear FLOAT,
	@HarshBraking FLOAT,
	@CO2 FLOAT,
	@OverSpeedDistance FLOAT,
	@Acceleration FLOAT,
	@Braking FLOAT,
	@Cornering FLOAT,
	@AccelerationLow FLOAT,
	@BrakingLow FLOAT,
	@CorneringLow FLOAT,
	@AccelerationHigh FLOAT,
	@BrakingHigh FLOAT,
	@CorneringHigh FLOAT,
	@CruiseTopGearRatio FLOAT,
	@OverRevCount FLOAT,
	@PTO FLOAT,
	@IVHOverspeed FLOAT,
	@ManoeuvresLow FLOAT,
	@ManoeuvresMed FLOAT,
	@Rop2 FLOAT,
	@rprtcfgid UNIQUEIDENTIFIER
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @score FLOAT
	SET @score = 
				  dbo.ScoreComponentClassConfig(@class, 1,  @SweetSpot, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 2,  @OverRevWithFuel, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 3,  @TopGear, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 4,  @Cruise, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 5,  @CoastInGear, @rprtcfgid)				
				+ dbo.ScoreComponentClassConfig(@class, 6,  @Idle, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 7,  @EngineServiceBrake, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 8,  @OverRevWithoutFuel, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 9,  @Rop, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 10, @OverSpeed, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 11, @CoastOutOfGear, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 12, @HarshBraking, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 20, @CO2, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 21, @OverSpeedDistance, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 22, @Acceleration, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 23, @Braking, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 24, @Cornering, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 33, @AccelerationLow, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 34, @BrakingLow, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 35, @CorneringLow, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 36, @AccelerationHigh, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 37, @BrakingHigh, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 38, @CorneringHigh, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 25, @CruiseTopGearRatio, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 28, @OverRevCount, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 29, @PTO, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 30, @IVHOverspeed, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 31, @CruiseInTopGears, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 32, @OverSpeedHigh, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 39, @ManoeuvresLow, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 40, @ManoeuvresMed, @rprtcfgid)
				+ dbo.ScoreComponentClassConfig(@class, 41, @Rop2, @rprtcfgid)
	
	RETURN @score
END


GO
