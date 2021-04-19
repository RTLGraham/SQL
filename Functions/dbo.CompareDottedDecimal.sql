SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[CompareDottedDecimal] (@dd1 VARCHAR(20), @dd2 VARCHAR(20))
RETURNS BIT	
AS	

BEGIN	

	--DECLARE @dd1 VARCHAR(20),
	--		@dd2 VARCHAR(20)
	--SET @dd1 = 'beta0'
	--SET @dd2 = '1.14.1'

	-- This function compares dotted decimals dd1 and dd2
	-- The dotted decimals must be 3 part and contain numerics only
	-- If dd1 is a later or equal version than dd2 it returns TRUE else it returns false

	DECLARE @dd1numeric BIGINT,
			@dd2numeric BIGINT,
			@check1 TINYINT,
			@check2 TINYINT,
			@result BIT	

	SELECT @check1 = SUM(ISNUMERIC(Value))
	FROM dbo.Split(@dd1, '.')

	SELECT @check2 = SUM(ISNUMERIC(Value))
	FROM dbo.Split(@dd2, '.')

	SET @result = NULL

	IF @check1 = 3 AND @check2 = 3
	BEGIN	

		SELECT @dd1numeric = SUM(CASE WHEN id = 1 THEN Value * 1000000 ELSE CASE WHEN id = 2 THEN Value * 1000 ELSE Value END END)
		FROM dbo.Split(@dd1, '.')

		SELECT @dd2numeric = SUM(CASE WHEN id = 1 THEN Value * 1000000 ELSE CASE WHEN id = 2 THEN Value * 1000 ELSE Value END END)
		FROM dbo.Split(@dd2, '.')

		SELECT @result = CASE WHEN @dd1numeric >= @dd2numeric THEN 1 ELSE 0 END	

	END	

	RETURN @result

END	
GO
