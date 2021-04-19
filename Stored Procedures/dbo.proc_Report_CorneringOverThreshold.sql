SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


/*
   Report on cornering events where speed is above a specified threshold relative to the vehicle speed limit for the road at that location.
   Results are formatted for export to Excel spreadsheet, in particlar the Location as a hyperlink to Google Maps.
*/

CREATE PROCEDURE [dbo].[proc_Report_CorneringOverThreshold]
    (
      @uid UNIQUEIDENTIFIER,
      @threshold INTEGER,
      @sdate DATETIME,
      @edate DATETIME
    )
AS 
	SET NOCOUNT ON;
	
	--DECLARE @uid UNIQUEIDENTIFIER
	--DECLARE @threshold INTEGER
	--DECLARE @sdate DATETIME
	--DECLARE @edate DATETIME

	--SET @uid = N'82FCE434-9E5E-4040-8FBF-585B76BC67CA'			--Piotr Krawczyk (Hoyer Poland AirLiquide)
	--SET @threshold = 15											--15kmh below actual vehicle speed limit
	--SET @sdate = '2018-12-01 00:00:00'
	--SET @edate = '2018-12-31 23:59:59'

	SELECT distinct
		g.GroupName, 
		v.Registration as Vehicle, 
		dbo.FormatDriverNameByUser(dbo.GetDriverIdFromInt(es.DriverIntId), @uid) AS Driver,
		es.Speed, 
		es.VehicleSpeedLimit as Limit,
		(es.Speed - es.VehicleSpeedLimit + @threshold) as OverSpeed,		-- cornering limit = (speed limit - 15kmh)
		es.EventDateTime as [Event Time], 
		concat('=HYPERLINK("https://www.google.co.uk/maps/place/', CONVERT(NVARCHAR(30),es.Lat), ',', CONVERT(NVARCHAR(30),es.Lon), '", "', es.StreetName, '")') as Location,
		es.StreetName as [Address],
		concat('https://www.google.co.uk/maps/place/', CONVERT(NVARCHAR(30),es.Lat), ',', CONVERT(NVARCHAR(30),es.Lon)) as Map
	FROM dbo.EventSpeeding es WITH (NOLOCK)
		INNER JOIN dbo.Vehicle v ON es.VehicleIntId = v.VehicleIntId
		inner join dbo.GroupDetail gd on gd.EntityDataId = v.VehicleId
		inner join dbo.[Group] g on g.GroupId = gd.GroupId
		inner join dbo.[UserGroup] ug on ug.GroupId = g.GroupId
	WHERE es.EventDateTime BETWEEN @sdate AND @edate 
		and ug.UserId = @uid
		AND v.Archived = 0
		AND es.CreationCodeId = 10						-- cornering events only
		AND (es.Lat != 0 AND es.Lon != 0)
		AND es.Speed >= 10
		and es.speedlimit < 255
		and es.VehicleSpeedLimit > 15					-- must allow speed threshold to be > 0kmh
		and es.speed > es.VehicleSpeedLimit - 15
	order by g.GroupName, v.Registration, es.EventDateTime


GO
