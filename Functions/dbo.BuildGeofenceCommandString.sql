SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[BuildGeofenceCommandString] 
(
	-- id of the geofence to build a command for,
	-- if this is null then we build geo command for 0,0 and use destid we were sent
	@geoId uniqueidentifier,
	-- we only use this destid if the geofence pulled above doesn't have a built in dest id or is null
	@destIdIn varchar(20)
)
RETURNS varchar(500)
AS
BEGIN
	DECLARE @commandString varchar(500)
	DECLARE @lat float
	DECLARE @lon float
	DECLARE @rad int
	DECLARE @destId varchar(20)
	DECLARE @name varchar(50)
	DECLARE @to smalldatetime
	DECLARE @crlf varbinary(2)

	SET @crlf = 0x0d0a

	-- get geofence details
	-- if geoId is NULL or deosn't exist then checks below will return an empty geofence def
	SELECT @lat = CenterLat, @lon = CenterLon, @rad = Radius2 * 1000, @destId = SiteId, @name = Name
		FROM dbo.GeoFence
		WHERE GeoFenceId = @geoId

	-- check result params
	IF @lat IS NULL
	BEGIN
		SET @lat = 0
	END
	IF @lon IS NULL
	BEGIN
		SET @lon = 0
	END
	IF @rad IS NULL
	BEGIN
		SET @rad = 100
	END
	IF @destId IS NULL
	BEGIN
		-- for some reason useing destidin here also adds 3 extra 00 bytes!
		-- this only happens when run from an sp not from the query editor
		SET @destId = '0' --@destIdIn
	END
	IF @name IS NULL
	BEGIN
		SET @name = 'No Name'
	END

	-- set timeout for now + 12 hours
	SELECT @to = DateAdd(hour, 12, GetDate())

	-- build response string
	--SELECT @commandString = '#REPL'

--	SELECT @commandString = '#WRITE,CGEOF,'+@destId+','+CAST(@lat AS varchar(12))+','+CAST(@lon AS varchar(12))+','+CAST(@rad AS varchar(10))+',3,'
--			+CAST(YEAR(@to) AS varchar(4))+'-'+CAST(MONTH(@to) AS varchar(2))+'-'+CAST(DAY(@to) AS varchar(2))+' '
--			+'23:59' -- wrong, should be hours:minutes from @to
--			+',"'+@name+'"'+CAST(@crlf AS varchar(2))

	SELECT @commandString = '#WRITE,CGEOF,'+@destId+','
			+dbo.GPSCoord_LatLongToCLFormat(@lat)+','
			+dbo.GPSCoord_LatLongToCLFormat(@lon)+','
			+CAST(@rad AS varchar(10))+',3,'
			+dbo.GPSCoord_DateToCLDateString(@to)
			+',"'+@name+'"'+CAST(@crlf AS varchar(2))

	RETURN @commandString

END









GO
