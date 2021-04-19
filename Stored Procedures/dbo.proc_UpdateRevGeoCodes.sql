SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_UpdateRevGeoCodes]
AS
BEGIN
	DECLARE @Latitude float
	DECLARE @Longitude float
	DECLARE @Address varchar(255)
	DECLARE @PostCode varchar(50)
	DECLARE @LatLongidx bigint

	CREATE TABLE #geocodes (long float, lat float, address varchar(255), postcode varchar(50), latlongidx bigint)
	CREATE TABLE #single (address varchar(255), postcode varchar(50))

	-- Find all trips and stops with lats and longs that don't have a cached address
	-- and insert into temporary table
	INSERT INTO #geocodes (long, lat)
	SELECT DISTINCT t.longitude, t.latitude
	FROM tripsandstops t
	WHERE UK_RTL2Application.dbo.GetAddressFromLongLat(t.Latitude, t.Longitude) is null
	  AND t.timestamp >= dateadd (dd, -2, getdate()) -- set to the number of days history to examine

	-- declare cursor to loop around the temp table and fill in additional data
	DECLARE geocursor CURSOR FAST_FORWARD READ_ONLY
	FOR SELECT lat, long FROM #geocodes
	OPEN geocursor
	FETCH NEXT FROM geocursor INTO @Latitude, @Longitude
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #single
		EXEC proc_GetAddressFromService @Latitude, @Longitude
		
		UPDATE #geocodes
		SET address = s.address, postcode = s.postcode, latlongidx = dbo.GetLatLongIdxFromLatLong(@Latitude, @Longitude)
		FROM #single s
		WHERE #geocodes.lat = @Latitude AND #geocodes.long = @Longitude

		DELETE FROM #single

		FETCH NEXT FROM geocursor INTO @Latitude, @Longitude
	END
	CLOSE geocursor
	DEALLOCATE geocursor

	DROP TABLE #single

	-- Insert the new data into revgeocode (justv taking distinct latlongidx values)
	INSERT INTO revgeocode (long, lat, address, postcode, latlongidx)
	SELECT max(long), max(lat), max(address), max(postcode), latlongidx
	FROM #geocodes
	WHERE latlongidx IS NOT NULL AND postcode IS NOT NULL
	GROUP BY latlongidx

	DROP TABLE #geocodes
END

GO
