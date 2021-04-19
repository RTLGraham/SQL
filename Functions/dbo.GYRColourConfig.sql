SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GYRColourConfig] (@Value FLOAT, @IndicatorId INT, @rprtcfgid UNIQUEIDENTIFIER)
RETURNS varchar(30) AS  
BEGIN 

/******************************************************************************/
/* This function returns the appropriate colour based on the colour bandings  */
/* and the score achieved for the given Indicator.                            */
/* As well as the colour bandings the following results have special meaning: */
/*   'Blue' means the indioator is not included in the configuration          */
/*    NULL  means the indicator is present but no colour is assigned          */
/******************************************************************************/

DECLARE @Result VARCHAR(30)
DECLARE @RedColour VARCHAR(50)
DECLARE @YellowColour VARCHAR(50)
DECLARE @GreenColour VARCHAR(50)
DECLARE @GoldColour VARCHAR(50)
DECLARE @SilverColour VARCHAR(50)
DECLARE @BronzeColour VARCHAR(50)
DECLARE @CopperColour VARCHAR(50)

SET @RedColour = 'Red'
SET @YellowColour = 'Amber'
SET @GreenColour = 'Green'
SET @GoldColour = 'Gold'
SET @SilverColour = 'Silver'
SET @BronzeColour = 'Bronze'
SET @CopperColour = 'Copper'

SELECT @Result = 
	CASE HighLow
	WHEN 1 THEN
		CASE
			WHEN GYRAmberMax = 0 AND GYRGreenMax = 0 AND ISNULL(GYRRedMax,0) = 0 THEN 'Empty'
			WHEN GYRRedMax IS NULL AND ROUND(@Value, Rounding) >= GYRGreenMax THEN @GreenColour
			WHEN GYRRedMax IS NULL AND ROUND(@Value, Rounding) >= GYRAmberMax AND ROUND(@Value, Rounding) < GYRGreenMax THEN @YellowColour
			WHEN GYRRedMax IS NULL AND ROUND(@Value, Rounding) < GYRAmberMax THEN @RedColour
			WHEN GYRRedMax IS NOT NULL AND ROUND(@Value, Rounding) >= GYRRedMax THEN @GoldColour
			WHEN GYRRedMax IS NOT NULL AND ROUND(@Value, Rounding) >= GYRAmberMax AND ROUND(@Value, Rounding) < GYRRedMax THEN @SilverColour
			WHEN GYRRedMax is NOT NULL AND ROUND(@Value, Rounding) >= GYRGreenMax AND ROUND(@Value, Rounding) < GYRAmberMax THEN @BronzeColour
			WHEN GYRRedMax IS NOT NULL AND ROUND(@Value, Rounding) < GYRGreenMax THEN @CopperColour
		END
	ELSE
		CASE
			WHEN GYRAmberMax = 0 AND GYRGreenMax = 0 AND ISNULL(GYRRedMax,0) = 0 THEN 'Empty'
			WHEN GYRRedMAX IS NULL AND ROUND(@Value, Rounding) <= GYRAmberMax THEN @GreenColour
			WHEN GYRRedMax IS NULL AND ROUND(@Value, Rounding) <= GYRGreenMax AND ROUND(@Value, Rounding) > GYRAmberMax THEN @YellowColour
			WHEN GYRRedMax IS NULL AND ROUND(@Value, Rounding) > GYRGreenMax THEN @RedColour
			WHEN GYRRedMax IS NOT NULL AND ROUND(@Value, Rounding) <= GYRRedMax THEN @GoldColour
			WHEN GYRRedMax IS NOT NULL AND ROUND(@Value, Rounding) <= GYRAmberMax AND ROUND(@Value, Rounding) > GYRRedMax THEN @SilverColour
			WHEN GYRRedMAx IS NOT NULL AND ROUND(@Value, Rounding) <= GYRGreenMax AND ROUND(@Value, Rounding) > GYRAmberMax THEN @BronzeColour
			WHEN GYRRedMax IS NOT NULL AND ROUND(@Value, Rounding) > GYRGreenMax THEN @CopperColour
		END
	END
FROM dbo.IndicatorConfig
INNER JOIN dbo.Indicator ON Indicator.IndicatorId = IndicatorConfig.IndicatorId
WHERE IndicatorConfig.IndicatorId = @IndicatorId AND IndicatorConfig.Archived = 0
AND ReportConfigurationId = @rprtcfgid

RETURN CASE WHEN @Result = 'Empty' THEN NULL ELSE ISNULL(@Result, 'Blue') END 

END



GO
