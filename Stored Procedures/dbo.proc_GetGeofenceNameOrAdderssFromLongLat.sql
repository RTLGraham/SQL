SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[proc_GetGeofenceNameOrAdderssFromLongLat]
    (
      @lat FLOAT,
      @lon FLOAT,
      @uid UNIQUEIDENTIFIER,
      @lookupGeo BIT,
      @cache BIT
    )
AS 
BEGIN 
	--DECLARE @uid UNIQUEIDENTIFIER,
	--		@lat FLOAT, 
	--		@lon FLOAT,
	--		@lookupGeo BIT,
	--		@cache BIT
			
	--SET @uid = N'8DA18520-50CA-402F-AE8E-6015B443B92C'
	--SET @lat = -38.062526	
	--SET @lon = 145.339966
	--SET @lookupGeo = 0
	--SET @cache = 1
	
	IF @lat IS NOT NULL AND @lon IS NOT NULL AND @lat != 0 AND @lon != 0
	BEGIN 
		DECLARE @result VARCHAR(255),
				@latlongidx BIGINT


		/**********************************************************/
		/*		Step 1: Geofence Name							  */
		/**********************************************************/
		IF @lookupGeo = 1
		BEGIN
			SELECT TOP 1
					@result = geo.Name
			FROM    dbo.UserGroup ug
					INNER JOIN dbo.[Group] g ON ug.GroupId = g.GroupId
												AND g.GroupTypeId = 4
												AND g.IsParameter = 0
												AND g.Archived = 0
					INNER JOIN dbo.GroupDetail gd ON g.GroupId = gd.GroupId
													 AND gd.GroupTypeId = 4
					INNER JOIN dbo.Geofence geo ON geo.GeofenceId = gd.EntityDataId
												   AND geo.Archived = 0
			WHERE   ug.UserId = @uid
					AND ug.Archived = 0
					--AND ST.Within(ST.Point(@lon, @lat, 4326), ST.Envelope(geo.the_geom)) = 1
					AND dbo.DistanceBetweenPoints(@lat, @lon,
															   geo.CenterLat,
															   geo.CenterLon) <= geo.Radius1
			ORDER BY dbo.DistanceBetweenPoints(@lat, @lon, geo.CenterLat, geo.CenterLon) ASC
		END

		/**********************************************************/
		/*		Step 2: Address from cache						  */
		/**********************************************************/
		SELECT  @latlongidx = dbo.[GetLatLongIdxFromLatLong](@lat, @lon)
		IF @result IS NULL 
		BEGIN	
			SELECT TOP 1
					@result = [Address]
			FROM    dbo.[RevGeocode]
			WHERE   latlongidx = @latlongidx
					AND [Address] NOT LIKE '%unknown%'
					AND [Address] <> ''
					AND Archived = 0
			ORDER BY revgeocodeid DESC
		END


		/**********************************************************/
		/*		Step 3: Address from cache (squares)			  */
		/**********************************************************/	
		IF @result IS NULL 
		BEGIN
			SELECT TOP 1
					@result = [Address]
			FROM    dbo.[RevGeocode]
			WHERE   latlongidx IN ( @latlongidx + 1, 
									@latlongidx - 1,
									@latlongidx + 10000000,
									@latlongidx - 10000000,
									@latlongidx + 10000001,
									@latlongidx + 9999999, 
									@latlongidx - 9999999, 
									@latlongidx - 10000001)
					AND [Address] NOT LIKE '%unknown%'
					AND [Address] <> ''
					AND Archived = 0
			ORDER BY revgeocodeid DESC
		END


		/**********************************************************/
		/*		Step 4: Address from service + write to cache	  */
		/**********************************************************/
		IF @result IS NULL 
		BEGIN
			SET @result = [dbo].GetAddressFromLongLat(@lat, @lon)
			SET @result = [dbo].[GetGeofenceNameFromLongLat] (@lat, @lon, @uid, @result)
			--SET @result = AU_Fleetwise.dbo.fn_GetAddressFromService(@lat, @lon)
			--IF @cache = 1
			--BEGIN
			--	EXEC dbo.[cuf_RevGeocode_Insert] @lat, @lon, @result, @latlongidx
			--END
		END

		/**********************************************************/
		/*		Step 6: No result								  */
		/**********************************************************/
		IF @result IS NULL 
		BEGIN
			SET @result = 'Address unknown'
		END

		SELECT @result
	END
	ELSE BEGIN
		SELECT 'Address unknown'
	END
END

GO
