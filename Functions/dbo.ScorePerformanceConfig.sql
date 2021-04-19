SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<D. Jurins>
-- Create date: <2010/10/27>
-- Description:	<Calculates the safety score>
-- =============================================
CREATE FUNCTION [dbo].[ScorePerformanceConfig]
(
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
	@CruiseTopGearRatio FLOAT,
	@rprtcfgid UNIQUEIDENTIFIER
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @score float
	SET @score = 
				  dbo.ScorePerfComponentValueConfig(1,  @SweetSpot*100, @rprtcfgid)
				+ dbo.ScorePerfComponentValueConfig(2,  @OverRevWithFuel*100, @rprtcfgid)
				+ dbo.ScorePerfComponentValueConfig(3,  @TopGear*100, @rprtcfgid)
				+ dbo.ScorePerfComponentValueConfig(4,  @Cruise*100, @rprtcfgid)
				+ dbo.ScorePerfComponentValueConfig(5,  @CoastInGear*100, @rprtcfgid)
				+ dbo.ScorePerfComponentValueConfig(6,  @Idle*100, @rprtcfgid)
				+ dbo.ScorePerfComponentValueConfig(7,  @EngineServiceBrake*100, @rprtcfgid)
				+ dbo.ScorePerfComponentValueConfig(8,  @OverRevWithoutFuel*100, @rprtcfgid)
				+ dbo.ScorePerfComponentValueConfig(9,  @Rop, @rprtcfgid)
				+ dbo.ScorePerfComponentValueConfig(10, @OverSpeed*100, @rprtcfgid)
				+ dbo.ScorePerfComponentValueConfig(11, @CoastOutOfGear*100, @rprtcfgid)
				+ dbo.ScorePerfComponentValueConfig(12, @HarshBraking, @rprtcfgid)
				+ dbo.ScorePerfComponentValueConfig(25, @CruiseTopGearRatio*100, @rprtcfgid)
	
	RETURN @score
END

GO
