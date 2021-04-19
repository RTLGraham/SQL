SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[DistanceBetweenPoints] (@lat1 float, @long1 float, @lat2 float, @long2 float)
RETURNS float AS  
BEGIN 
	-- earth radius in km in UK = 6360
	-- radian = 57.295779513

	DECLARE @distance float
	DECLARE @radian float
	DECLARE @earthradius float
	DECLARE @tempresult float
	SET @radian = 57.295779513
	SET @earthradius = 6360

	-- convert to radians
	SET @lat1 = @lat1 / @radian
	SET @lat2 = @lat2 / @radian
	SET @long1 = @long1 / @radian
	SET @long2 = @long2 / @radian

	SET @tempresult = ( COS(@lat1)*COS(@lat2)*COS(@long2-@long1) ) + ( SIN(@lat1)*SIN(@lat2) )
	IF @tempresult > 1 or @tempresult < -1
		SET @distance = 0
	ELSE 
		SET @distance = ACOS(@tempresult) * @earthradius


RETURN @distance

END

GO
