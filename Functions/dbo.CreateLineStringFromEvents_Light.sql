SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[CreateLineStringFromEvents_Light]
(
	@vintid INT,
	@sdate DATETIME,
	@edate DATETIME
) RETURNS VARBINARY(MAX)
AS
BEGIN
	DECLARE @linestring_wkt NVARCHAR(MAX),
			@lat FLOAT,
			@lon FLOAT,
			@wkb varbinary(max),
			@counter INT
	
	SET @counter = 0
	
	DECLARE linestr_cur CURSOR FAST_FORWARD READ_ONLY FOR
		SELECT e.Lat, e.Long
		FROM dbo.Event e
			INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
		WHERE e.VehicleIntId = @vintid
		AND EventDateTime BETWEEN @sdate AND @edate
		AND lat != 0 AND long != 0
		ORDER BY EventDateTime

	SET @linestring_wkt = 'LINESTRING('
	OPEN linestr_cur
	FETCH NEXT FROM linestr_cur INTO @lat, @lon
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @linestring_wkt = @linestring_wkt + CAST(@lon AS VARCHAR(20)) + ' ' + CAST(@lat AS VARCHAR(20))

		SET @counter = @counter + 1
		
		FETCH NEXT FROM linestr_cur INTO @lat, @lon
		IF (@@FETCH_STATUS = 0)
			SET @linestring_wkt = @linestring_wkt + ','
	END
	CLOSE linestr_cur
	DEALLOCATE linestr_cur
	SET @linestring_wkt = @linestring_wkt + ')'
	
	IF (@linestring_wkt = 'LINESTRING()') OR (@counter <= 1)
		set @wkb = null
	else
		set @wkb = ST.LineFromText(@linestring_wkt,4326)
	return @wkb
END


GO
