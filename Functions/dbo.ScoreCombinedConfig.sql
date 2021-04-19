SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<D. Jurins>
-- Create date: <2010/10/27>
-- Description:	<Calculates the safety score>
-- =============================================
CREATE FUNCTION [dbo].[ScoreCombinedConfig]
(
	@SweetSpot FLOAT,
	@OverRevWithFuel FLOAT,
	@TopGear FLOAT,
	@Cruise FLOAT,
	@Idle FLOAT,
	@CruiseTopGearRatio FLOAT,
	@EngineServiceBrake FLOAT,
	@OverRevWithoutFuel FLOAT,
	@Rop FLOAT,
	@OverSpeed FLOAT,
	@CoastOutOfGear FLOAT,
	@HarshBraking FLOAT,
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
				+ dbo.ScoreComponentValueConfig(6,  @Idle, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(7,  @EngineServiceBrake, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(8,  @OverRevWithoutFuel, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(9,  @Rop, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(10, @OverSpeed, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(11, @CoastOutOfGear, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(12, @HarshBraking, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(25, @CruiseTopGearRatio, @rprtcfgid)
	
	RETURN @score
END

GO
