SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[TrimLeftRightNonAlphaNumerics] (@input nvarchar(MAX))
RETURNS nvarchar(MAX) AS  
BEGIN 
	DECLARE @result NVARCHAR(MAX)
    SELECT @result = REVERSE(SUBSTRING(REVERSE(SUBSTRING(@input, PATINDEX('%[a-zA-Z0-9]%', @input), 
        LEN(@input))), PATINDEX('%[a-zA-Z0-9]%', REVERSE(SUBSTRING(@input, 
        PATINDEX('%[a-zA-Z0-9]%', @input), LEN(@input)))), LEN(@input)))
        
   RETURN @result
END


GO
