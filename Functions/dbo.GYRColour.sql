SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GYRColour] (@Value FLOAT, @IndicatorId INT, @DepotId INT)
RETURNS varchar(30) AS  
BEGIN 

--SELECT * FROM dbo.IndicatorsDepots WHERE IndicatorId = 2
--SELECT * FROM dbo.Indicators WHERE IndicatorId = 2

--DECLARE @Value FLOAT,
--		@IndicatorId INT,
--		@DepotId INT

--SET @Value = 18
--SET @IndicatorId = 2
--SET @DepotId = 10

DECLARE @RedColour VARCHAR(50)
DECLARE @YellowColour VARCHAR(50)
DECLARE @GreenColour VARCHAR(50)

SET @RedColour = 'Red'
SET @YellowColour = 'Amber'
SET @GreenColour = 'Green'

RETURN (
	SELECT TOP 1
		CASE HighLow
		WHEN 1 THEN
			CASE
				WHEN @Value <= GYRAmberMax AND @Value > GYRGreenMax THEN @YellowColour
				WHEN @Value > GYRAmberMax THEN @GreenColour
				WHEN @Value <= GYRGreenMax THEN @RedColour
			END
		ELSE
			CASE 
				WHEN @Value <= GYRAmberMax THEN @GreenColour
				WHEN @Value < GYRGreenMax AND @Value >= GYRAmberMax THEN @YellowColour
				WHEN @Value > GYRAmberMax THEN @RedColour
			END
		END
		AS Colour
	FROM dbo.Indicators
		INNER JOIN dbo.IndicatorsDepots ON Indicators.IndicatorId = IndicatorsDepots.IndicatorId
	WHERE Indicators.IndicatorId = @IndicatorId
	AND ((DepotId = @DepotId) OR (DepotId IS NULL))
	ORDER BY DepotId DESC)
	
END

--select * from dbo.indicators i
--inner join dbo.indicatorsdepots id on i.indicatorid = id.indicatorid
--where i.indicatorid = 7
--and ((depotid = 96) or (depotid is null))



GO
