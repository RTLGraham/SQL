SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_WriteRevGeocode] @long float, @lat float, @address varchar(100), @pcode varchar(50) = NULL
AS
--IF @address IS NULL
	DECLARE @LatLongIdx bigint
	DECLARE @RevGeoCodeID int
	SET @LatLongIdx = CAST((@lat + 90) * 1000 as bigint)*1000000+CAST((@long + 180) * 1000 as bigint)
	SELECT @RevGeoCodeID = RevGeoCodeID from RevGeoCode Where LatLongIdx = @LatLongIdx and Archived = 0
	IF @pcode is null or @pcode = ''
	BEGIN
	Set @pcode = 'N/A'
	END
	IF @address like 'GMT%'
	BEGIN
	Set @address = 'Address Unknown'
	END
	IF @address like '%(postcode)%'
	BEGIN
		Set @Address = Replace(@address,'(postcode)','')
	END
	IF @address like '%(sea)%'
	BEGIN
		Set @Address = Replace(@address,'(sea)','')
	END
	IF @address like '%(ocean)%'
	BEGIN
		Set @Address = Replace(@address,'(ocean)','')
	END
	IF @address like '%(census tract)%'
	BEGIN
		Set @Address = Replace(@address,'(census tract)','')
	END
	IF @address like '%(historical region)%'
	BEGIN
		Set @Address = Replace(@address,'(historical region)','')
	END
	IF @RevGeoCodeID is null
	BEGIN
		declare @count int
		select @count = count(*) from RevGeocode where latlongidx = @LatLongIdx and archived = 0
		if @count = 0
		BEGIN
			INSERT INTO RevGeocode (Long, Lat, [Address], Postcode,LatLongIdx) VALUES (@long, @lat, @address,@pcode,@LatLongIdx)
		END
		ELSE
		BEGIN
			Update RevGeocode set archived = 1 where latlongidx = @LatLongIdx
			INSERT INTO RevGeocode (Long, Lat, [Address], Postcode,LatLongIdx) VALUES (@long, @lat, @address,@pcode,@LatLongIdx)
		END
	END
--ELSE
	--UPDATE RevGeocode SET Address = @address WHERE CAST(Long AS decimal(38,5)) = CAST(@long AS decimal(38,5)) AND CAST(Lat AS decimal(38,5)) = CAST(@lat AS decimal(38,5))
	
	IF @RevGeoCodeID is null
	BEGIN
		SELECT SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		Select @RevGeoCodeID
	END

GO
