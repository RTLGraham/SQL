SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<D. Jurins>
-- Create date: <2010/10/27>
-- Description:	<Calculates the efficiency score
--				HighLow = 0 => weight * (HIGH - @value) / (HIGH - LOW)
--				HighLow = 1 => weight * (@value - LOW) / (HIGH - LOW)
-- =============================================
CREATE FUNCTION [dbo].[ScoreEfficiencyConfig]
(
	@SweetSpot FLOAT,
	@OverRevWithFuel FLOAT,
	@TopGear FLOAT,
	@Cruise FLOAT,
	@Idle FLOAT,
	@CruiseTopGearRatio FLOAT,
	@rprtcfgid UNIQUEIDENTIFIER
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @score float
	
	SET @score = 
				  dbo.ScoreComponentValueConfig(1, @SweetSpot, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(2, @OverRevWithFuel, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(3, @TopGear, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(4, @Cruise, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(6, @Idle, @rprtcfgid)
				+ dbo.ScoreComponentValueConfig(25,@CruiseTopGearRatio, @rprtcfgid)

	
	RETURN @score
END

GO
