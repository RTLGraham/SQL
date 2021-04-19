SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[ScaleConvertAnalogValue] 
(
	@value SMALLINT,
	@scale FLOAT,
	@tempmult FLOAT,
	@liquidmult FLOAT
)
RETURNS FLOAT
AS
BEGIN

	DECLARE @result FLOAT
	  
	SET @result = @value * ISNULL(@scale,1)
	  
	IF @scale IN (0.00390625) -- The value is a temperature
		SELECT @result = CASE WHEN @tempmult = 1.8 THEN @result * @tempmult + 32 ELSE @result * @tempmult END
	--ELSE IF @scale IN (0.1) -- The value is a liquid volume
	--	SELECT @result = @result * @liquidmult

	RETURN @result
END



GO
