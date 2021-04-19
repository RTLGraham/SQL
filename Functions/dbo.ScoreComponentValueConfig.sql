SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<D. Jurins>
-- Create date: <2010/10/27>
-- Description:	<Returns a factor component (value) in score calculation>
-- =============================================
CREATE FUNCTION [dbo].[ScoreComponentValueConfig]
(
	@factorId INT,
	@factor FLOAT,
	@rprtcfgid UNIQUEIDENTIFIER
)
RETURNS FLOAT
AS
BEGIN

	DECLARE @value FLOAT,
			@highlow BIT,
			@weight FLOAT,
			@type VARCHAR(2),
			@min FLOAT,
			@max FLOAT
	
	SELECT  @highlow = HighLow,
			@weight = Weight,
			@type = [Type],
			@min = Min,
			@max = Max
	FROM dbo.[ReportIndicatorConfig] 
	WHERE IndicatorId = @factorId 
	  AND ReportConfigurationId = @rprtcfgid
	
	IF @highlow = 1
	BEGIN
		-- (weight * (@value - LOW) / (HIGH - LOW))
		SET @value = CAST(@weight * (CASE WHEN @type='P' THEN @factor * 100 ELSE @factor END - @min) / CASE WHEN (@max - @min) = 0 THEN 1 ELSE (@max - @min) END AS FLOAT)
	END
	ELSE IF @highlow = 0
	BEGIN
		-- (weight * (HIGH - @value) / (HIGH - LOW))
		SET @value = CAST(@weight * (@min - CASE WHEN @type='P' THEN @factor * 100 ELSE @factor END) / CASE WHEN (@min - @max) = 0 THEN 1 ELSE (@min - @max) END  AS FLOAT)
	END
	ELSE
	BEGIN
		--no value found
		SET @value = 0
	END
	
	RETURN @value
END

GO
