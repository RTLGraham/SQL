SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<D. Jurins>
-- Create date: <2010/10/27>
-- Description:	<Calculates the safety score>
-- =============================================
CREATE FUNCTION [dbo].[ScoreSafetyConfig]
(
	@CoastInGear FLOAT,
	@EngineServiceBrake FLOAT,
	@OverRevWithoutFuel FLOAT,
	@Rop FLOAT,
	@OverSpeed FLOAT,
	@CoastOutOfGear FLOAT,
	@HarshBraking FLOAT,
	@Acceleration FLOAT,
	@Braking FLOAT,
	@Cornering FLOAT,
	@rprtcfgid UNIQUEIDENTIFIER
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @score float
	SET @score = 
				  ISNULL(dbo.ScoreComponentValueConfig(5, @CoastInGear, @rprtcfgid), 0)
				+ ISNULL(dbo.ScoreComponentValueConfig(7, @EngineServiceBrake, @rprtcfgid), 0)
				+ ISNULL(dbo.ScoreComponentValueConfig(8, @OverRevWithoutFuel, @rprtcfgid), 0)
				+ ISNULL(dbo.ScoreComponentValueConfig(9, @Rop, @rprtcfgid), 0)
				+ ISNULL(dbo.ScoreComponentValueConfig(10, @OverSpeed, @rprtcfgid), 0)
				+ ISNULL(dbo.ScoreComponentValueConfig(11, @CoastOutOfGear, @rprtcfgid), 0)
				+ ISNULL(dbo.ScoreComponentValueConfig(12, @HarshBraking, @rprtcfgid), 0)
				+ ISNULL(dbo.ScoreComponentValueConfig(22, @Acceleration, @rprtcfgid), 0)
				+ ISNULL(dbo.ScoreComponentValueConfig(23, @Braking, @rprtcfgid), 0)
				+ ISNULL(dbo.ScoreComponentValueConfig(24, @Cornering, @rprtcfgid), 0)
	
	RETURN @score
END

GO
