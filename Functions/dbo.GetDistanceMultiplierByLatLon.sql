SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<D. Jurins>
-- Create date: <10.12.2012>
-- Description:	<Returns the distance multiplier for the given lat/long>
-- =============================================
CREATE FUNCTION [dbo].[GetDistanceMultiplierByLatLon]
(
	@lat FLOAT,
	@lon FLOAT
)
RETURNS FLOAT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @result FlOAT
	SET @result = 1.60934
	
	/*		Partial Europe bounding box 
		58.4, 3.7		58.4, 37.4
		36.2, 3.7		36.2, 37.4
	*/   
	IF ((@Lat >= 36.2 AND @Lat <= 58.4) AND (@Lon >= 3.7 AND @Lon <= 37.4))
	BEGIN
		SET @result = 1
	END
	
	RETURN @result
END

GO
