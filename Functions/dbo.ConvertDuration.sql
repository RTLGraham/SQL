SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[ConvertDuration]	(@duration BIGINT)
RETURNS VARCHAR(MAX) AS  
BEGIN 
	
	DECLARE @result VARCHAR(MAX)
	DECLARE @seconds INT,
			@minutes INT,
			@hours INT,
			@days INT
	
	SET @seconds = @duration % 60
	SET @minutes = ((@duration - @seconds) / 60) % 60
	SET @hours = ((((@duration - @seconds) / 60) - @minutes) / 60) % 24
	SET @days = (((((@duration - @seconds) / 60) - @minutes) / 60) - @hours) / 24
	
	IF @days > 0
		SET @result = CAST(@days AS VARCHAR(2)) + 'd ' + CAST(@hours AS VARCHAR(2)) + 'h ' + CAST(@minutes AS VARCHAR(2)) + 'm ' + CAST(@seconds AS VARCHAR(2)) + 's'
	ELSE	
		IF @hours > 0
			SET @result = CAST(@hours AS VARCHAR(2)) + 'h ' + CAST(@minutes AS VARCHAR(2)) + 'm ' + CAST(@seconds AS VARCHAR(2)) + 's'
		ELSE	
			IF @minutes > 0
				SET	@result = CAST(@minutes AS VARCHAR(2)) + 'm ' + CAST(@seconds AS VARCHAR(2)) + 's'
			ELSE
				IF @seconds > 0
					SET @result = CAST(@seconds AS VARCHAR(2)) + 's'
				ELSE
					SET @result = 'N/A'

	RETURN @result

END

GO
