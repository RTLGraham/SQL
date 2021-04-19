SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****** Object:  StoredProcedure [dbo].[proc_ReportMaintenance]    Script Date: 09/21/2011 12:14:55 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

CREATE PROCEDURE [dbo].[proc_ReportBlobs]
    (
      @vids varchar(max),
      @sdate datetime,
      @edate datetime,
      @uid UNIQUEIDENTIFIER
    )
AS 
    SET NOCOUNT ON
	--DECLARE @vids varchar(max),
	--    @sdate datetime,
	--    @edate datetime,
	--    @uid uniqueidentifier

	--SET @vids = N'91f8ffd7-704b-4194-b6f5-d95209e1a033'
	--SET @sdate = '2011-12-08 00:00'
	--SET @edate = '2011-12-08 23:59'
	--SET @uid = N'0b9c8586-fb6b-464d-b135-5329f47e5ba2'



	SET @sdate = [dbo].TZ_ToUTC(@sdate, default, @uid)
    SET @edate = [dbo].TZ_ToUTC(@edate, default, @uid)

	SELECT	v.VehicleId, v.Registration,
			d.DriverId, d.Surname + ' ' + d.Firstname as DriverName, d.Number AS DriverNumber,
			dbo.TZ_GetTime(e.EventDateTime, DEFAULT, @uid) AS EventDateTime,
			eb.EventBlobId AS EventsBlobsId,
			eb.Blob,
			dbo.GetBlobDescription(eb.Blob) AS BlobDescription,
			ISNULL(eb.SeverityId, 2) AS SeverityId,
			e.Lat,
			e.Long,
			dbo.GetAddressFromLongLat(e.Lat, e.Long) AS BlobLocation,
			dbo.TZ_GetTime(@sdate, DEFAULT, @uid) AS CreationDateTime,
			dbo.TZ_GetTime(@edate, DEFAULT, @uid) AS ClosureDateTime
	FROM dbo.EventBlob eb
		INNER JOIN dbo.Event e ON eb.EventId = e.EventId AND e.VehicleIntId = eb.VehicleIntId AND eb.CustomerIntId = e.CustomerIntId
		LEFT OUTER JOIN dbo.Driver d ON e.DriverIntId = d.DriverIntId
		INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
	WHERE v.VehicleId IN ( SELECT Value
							FROM   dbo.Split(@vids, ',') )
		 AND eb.EventDateTime BETWEEN @sdate AND @edate


GO
