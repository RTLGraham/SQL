SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[cuf_RevGeocode_WriteRevGeocode]
(
	@lat float,
	@lon float,
	@address varchar(100),
	@pcode varchar(50) = NULL,
	@confidence CHAR(1) = NULL
)
AS
	DECLARE @LatLongIdx BIGINT
	DECLARE @RevGeoCodeID INT
	SET @LatLongIdx = CAST((@lat + 90) * 1000 as bigint)*1000000+CAST((@lon + 180) * 1000 as bigint)
	SELECT @RevGeoCodeID = RevGeoCodeID from [dbo].[RevGeoCode] Where LatLongIdx = @LatLongIdx and Archived = 0
	
	IF @confidence IS NULL	
	BEGIN
		SET @confidence = 'M'
	END
	
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
		DECLARE @count int
		SELECT @count = count(*) FROM [dbo].[RevGeocode] WHERE latlongidx = @LatLongIdx and archived = 0
		IF @count = 0
		BEGIN
			INSERT INTO [dbo].[RevGeocode] (Long, Lat, [Address], Postcode,LatLongIdx, Confidence) VALUES (@lon, @lat, @address,@pcode,@LatLongIdx,@confidence)
		END
		ELSE
		BEGIN
			UPDATE [dbo].[RevGeocode] SET archived = 1 WHERE latlongidx = @LatLongIdx
			INSERT INTO [dbo].[RevGeocode] (Long, Lat, [Address], Postcode,LatLongIdx,Confidence) VALUES (@lon, @lat, @address,@pcode,@LatLongIdx,@confidence)
		END
	END
	ELSE
	BEGIN
		UPDATE RevGeocode 
		SET InsertDateTime = GETDATE(),
			Postcode = @pcode,
			Confidence = @confidence,
			Address = @address 
		WHERE RevGeocodeId = @RevGeoCodeID
	END
	
	IF @RevGeoCodeID is null
	BEGIN
		SELECT SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		Select @RevGeoCodeID
	END

GO
