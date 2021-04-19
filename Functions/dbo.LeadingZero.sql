SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[LeadingZero] (@number int, @length int)
RETURNS varchar(20) AS  
BEGIN 
DECLARE @string varchar(20)

SET @string = CAST(@number AS varchar(20))
SET @string = REPLICATE('0', @length - LEN(@string)) + @string

RETURN @string

END

GO
