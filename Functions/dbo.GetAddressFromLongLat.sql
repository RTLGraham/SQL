SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetAddressFromLongLat] (@lat float, @lon float)
RETURNS varchar(255) AS  
BEGIN 
	DECLARE @address varchar(255)
	DECLARE @pcode varchar(50)
	DECLARE @bit bit
	DECLARE @latlongidx bigint
	
	SELECT @latlongidx = dbo.[GetLatLongIdxFromLatLong] ( @lat, @lon );
	
	--check exact location first
	SELECT TOP 1 @address = CASE WHEN 
		ASCII(LEFT([Address],1)) > 48 AND ASCII(LEFT([Address],1)) < 58 THEN RIGHT([Address], LEN([Address]) - CHARINDEX(' ', [Address])) ELSE 
		[Address] END, @bit = Archived, @pcode = Postcode
	FROM dbo.[RevGeocode]
	WHERE latlongidx = @latlongidx
	--and [Address] not like '%unknown%' and [Address] <> ''
	and [Address] <> ''
	order by revgeocodeid desc

	--check adjacent N,S,E,W squares
	IF @address is NULL
	BEGIN
	SELECT TOP 1 @address = CASE WHEN 
			ASCII(LEFT([Address],1)) > 48 AND ASCII(LEFT([Address],1)) < 58 THEN RIGHT([Address], LEN([Address]) - CHARINDEX(' ', [Address])) ELSE 
			[Address] END, @bit = Archived, @pcode = Postcode
	FROM dbo.[RevGeocode]
	WHERE latlongidx in (@latlongidx + 1, @latlongidx - 1, @latlongidx + 1000000, @latlongidx - 1000000)
	--and [Address] not like '%unknown%' and [Address] <> ''
	 and [Address] <> ''
	order by revgeocodeid desc
	END

	--check adjacent NE,NW,SE,SW squares
	IF @address is NULL
	BEGIN
	SELECT TOP 1 @address = CASE WHEN 
		ASCII(LEFT([Address],1)) > 48 AND ASCII(LEFT([Address],1)) < 58 THEN RIGHT([Address], LEN([Address]) - CHARINDEX(' ', [Address])) ELSE 
		[Address] END, @bit = Archived, @pcode = Postcode
	FROM dbo.[RevGeocode]
	WHERE latlongidx in (@latlongidx + 1000001, @latlongidx + 999999, @latlongidx - 999999, @latlongidx - 1000001)
	--and [Address] not like '%unknown%' and [Address] <> ''
	 and [Address] <> ''
	order by revgeocodeid desc
	END
	
	RETURN @address
END

GO
