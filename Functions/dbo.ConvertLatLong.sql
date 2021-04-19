SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[ConvertLatLong]	(@LatLong FLOAT)
RETURNS VARCHAR(MAX) AS  
BEGIN 
	--DECLARE @LatLong FLOAT
	--SET @LatLong = -0.5177
	
	DECLARE @result VARCHAR(MAX)
	DECLARE @degrees INT,
			@minutes INT,
			@seconds FLOAT,
			@sign CHAR(1)
	
	SET @sign = CASE WHEN @LatLong < 0 THEN '-' ELSE ' ' END	
	SET @degrees = CASE WHEN @LatLong < 0 THEN CEILING(@LatLong) ELSE FLOOR(@LatLong) END	
	SET @minutes = CASE WHEN @LatLong < 0 THEN FLOOR((@LatLong - @degrees) * -60) ELSE FLOOR((@LatLong - @degrees) * 60) END 
	SET @seconds = CASE WHEN @LatLong < 0 THEN (((@LatLong - @degrees) * -60) - @minutes) * 60 ELSE (((@LatLong - @degrees) * 60) - @minutes) * 60 END 

	SET @degrees = ABS(@degrees)
	SET @result = LTRIM(RIGHT('  ' + @sign + CAST(@degrees AS VARCHAR(4)), 4) + RIGHT('0' + CAST(@minutes AS VARCHAR(2)), 2) + RIGHT('0' + CAST(FLOOR(@seconds) AS VARCHAR(2)), 2) + SUBSTRING(CAST(@seconds AS VARCHAR(MAX)), CHARINDEX('.', CAST(@seconds AS VARCHAR(MAX))) + 1, 1))

	RETURN @result

END




GO
