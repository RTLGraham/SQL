SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[TrimSiteId] (@strin varchar(1024))
RETURNS varchar(1024) AS  
BEGIN
	IF  CHARINDEX(',',@strin,1) > 0 -- String contains a comma so we need to strip subsequent characters
		SET @strin = LEFT(@strin,charindex(',',@strin,1)-1)
	DECLARE @idx int
	SET @idx = 1
	WHILE (@idx <= Len(@strin) AND (SUBSTRING(@strin, @idx, 1) = '0' OR SUBSTRING(@strin, @idx, 1) = ' '))
	-- Stops looping at string end or upon the first comma
	BEGIN
		SET @idx = @idx + 1
	END	
	RETURN RTRIM(SUBSTRING(@strin, @idx, LEN(@strin)-@idx+1))
END

GO
