SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<D. Jurins>
-- Create date: <2010/10/27>
-- Description:	<Calculates the safety score>
-- =============================================
CREATE FUNCTION [dbo].[ScoreByConfig]
(
	@class CHAR(1),
	@SweetSpot FLOAT,
	@OverRevWithFuel FLOAT,
	@TopGear FLOAT,
	@Cruise FLOAT,
	@CoastInGear FLOAT,
	@Idle FLOAT,
	@EngineServiceBrake FLOAT,
	@OverRevWithoutFuel FLOAT,
	@Rop FLOAT,
	@OverSpeed FLOAT,
	@CoastOutOfGear FLOAT,
	@HarshBraking FLOAT,
	@CO2 FLOAT,
	@OverSpeedDistance FLOAT,
	@Acceleration FLOAT,
	@Braking FLOAT,
	@Cornering FLOAT,
	@CruiseTopGearRatio FLOAT,
	@OverRevCount FLOAT,
	@PTO FLOAT,
	@rprtcfgid UNIQUEIDENTIFIER
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @score float
	SET @score = 
				  dbo.ScoreComponentValueConfig(1,  @SweetSpot, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(2,  @OverRevWithFuel, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(3,  @TopGear, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(4,  @Cruise, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(5,  @CoastInGear, @rprtcfgid)				
				+ dbo.ScoreComponentValueConfig(6,  @Idle, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(7,  @EngineServiceBrake, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(8,  @OverRevWithoutFuel, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(9,  @Rop, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(10, @OverSpeed, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(11, @CoastOutOfGear, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(12, @HarshBraking, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(20, @CO2, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(21, @OverSpeedDistance, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(22, @Acceleration, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(23, @Braking, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(24, @Cornering, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(25, @CruiseTopGearRatio, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(28, @OverRevCount, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(29, @PTO, @rprtcfgid)
	
	RETURN @score
END


GO
