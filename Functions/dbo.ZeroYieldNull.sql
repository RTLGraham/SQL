SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[ZeroYieldNull] (@valuetocheck float)
RETURNS float AS  
BEGIN 
DECLARE @valuetoreturn float

	SET @valuetoreturn = CASE WHEN @valuetocheck = 0 THEN NULL ELSE @valuetocheck END

	RETURN @valuetoreturn

END

GO
