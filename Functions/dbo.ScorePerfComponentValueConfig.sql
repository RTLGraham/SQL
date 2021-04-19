SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<D. Jurins>
-- Create date: <2010/10/27>
-- Description:	<Returns a factor component (value) in score calculation>
-- =============================================
CREATE FUNCTION [dbo].[ScorePerfComponentValueConfig]
(
	@factorId INT,
	@factor FLOAT,
	@rprtcfgid UNIQUEIDENTIFIER
)
RETURNS FLOAT
AS
BEGIN

	DECLARE @value FLOAT
	  
	SET @value = ISNULL(dbo.IndWeightConfig(@factorId, @rprtcfgid) * 
	CASE dbo.GYRColourConfig(@factor, @factorId, @rprtcfgid)
		WHEN 'Copper' THEN 4
		WHEN 'Bronze' THEN 3
		WHEN 'Silver' THEN 2
		WHEN 'Gold' THEN 1
	END, 
	0)
		
	RETURN @value
END

GO
