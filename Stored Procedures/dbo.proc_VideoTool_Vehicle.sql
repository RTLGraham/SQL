SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_VideoTool_Vehicle]
    (
      @vids NVARCHAR(MAX),
      @status VARCHAR(MAX),
      @uid UNIQUEIDENTIFIER,
      @sdate DATETIME,
      @edate DATETIME
    )
AS 
	--DECLARE	@sdate DATETIME,
	--		@edate DATETIME,
	--		@uid UNIQUEIDENTIFIER,
	--		@vids NVARCHAR(MAX),
	--		@status VARCHAR(MAX)
			
	--SET @sdate = '2020-11-13 00:00'
	--SET @edate = '2020-11-15 23:59'
	--SET @uid = N'988D25DE-65E9-4FC5-8981-3D2B4EA0FEAB'
	----SET @vids = N'A7E91129-C0CA-4997-9430-E0CB0BEFA67D,1271B07A-0843-4F68-8966-FAE8A7B04625,CFD73625-A271-4B62-9B7E-090A1C447FE2,9F455593-A172-40E9-BAB1-4D4558C26EF7,DC4FC001-7C9D-4F7D-9291-E76943230B99,845C485E-92D6-4147-91D9-40886B1A67CB,417702DA-EA3D-4802-98C8-C0A9DAE4ABD8,B73257E8-ED6F-4625-963B-FF0671717CB7,09058B1C-B80E-495C-8C77-0B6534ABEB82,976B0642-37F3-463B-A9F8-7D5F2731D31E,7F4FDF26-2C28-4462-8EC2-874855BEDD65,980835E4-0F02-4E1E-8F68-A3D695D68E7A,94B30812-DD1A-4C8F-86FA-F68198B2C455,4BD17005-B5DF-4BA3-8FD1-B7A30A5DE61E,FD7EE43B-8E1E-480D-954C-44ED3304EE37,BC7A8D6C-6895-48B8-986C-0233B656BA75,5180BC54-E298-4125-AF3D-2741D3CD11C2,70674D37-F98E-40F0-B37A-8EC89D74096A,6E5C3284-466E-4826-A223-B5F5DE1F03D8,149F826C-EABB-4BA1-917A-01A8B85C535A,2E7D34A1-664A-4C8A-A434-5B7F4D211D5F,29009384-B0FA-47C2-8BF3-4B5CAF70091B,F15E348B-6082-4C36-9C9C-6C37C16A3716,32A2BA60-B5AD-4907-8785-80B628C7DAF0,E84EE304-B580-4C44-88E6-4255D7481EFE,60F770BA-22B5-4835-B43A-4765D19CAA90,A1D72DD5-A502-42CA-9199-A7D2FF2B6D44,5E7C1DDC-79A5-48A0-8F16-2CD9C2E1E9B9,C3D52D76-1862-462D-B495-5ED671C8A1D2,E6DE3830-2A86-4AF3-BBFF-4DF6FA28080E,8D89EA28-BE16-448B-AD89-A24652FBB04E,13AA0D45-5D1F-423C-9F0E-9722C8A0C9CA,A181926B-22F9-45B2-A712-851DC7E0A608,AE8A882B-C0B9-40F2-83B3-FFD450D9EFED,B7A58AF9-83B4-4492-B71B-462D8CA9866B,47FF50CC-ED55-4EAA-954A-D0F3B74112A0,A1B19009-919F-4FEA-8D7B-6F03DF9AE1DF,68721635-7B4E-4169-B7E9-27BA7C9C35BA,881F01DC-1D87-4156-8C72-9602682901F7,3CAF9FE5-12CC-4311-8795-0D10B1979A19,AA039F46-3CC9-42FF-9960-92F81F3C8510,284C0AA4-9CA1-464D-AB8B-ACE4AF9B3B5D,09ED18D1-42E8-45C9-87C3-083495BAA71E,C6144B5B-73D5-4B2B-B522-97748AB2EB8D,BC79BFC7-F949-4F4A-B10D-F8730DF9C208,A79794F1-6213-46B4-B315-4D72BBDB315E,FA614670-05A0-403B-BFF9-02F9AD3CC2CB,345A68C5-7BFB-423C-8164-96A77C946714,CD7BB159-6753-4BD6-AA5B-488F183F350C,06C744B8-3A3D-4957-8FD3-BD8AF473D629,63256A47-2C0C-4419-9BE2-430AD9B74A80,E7CA5936-0879-402B-9F16-3DA50AF75A00,96905EE0-53A2-448D-8F9C-47C93F766B61,F88D4581-3BDC-496B-8D05-286D7A7CE499,5D71C0DB-8BB7-4EF5-9814-1053C05F6935,6074423C-8973-4A94-B0A6-3CB7687D5A6D,DF451416-CEE9-4F3C-BFD1-9FCBCC77F4E3,2E7883CD-804A-4A6B-96CA-4DD1495AD6EE,5D82CE4A-A526-460F-A7BF-B32A4AE42EC6,6AD86E18-B0A0-4525-B3FB-257C3F36522B,CC4CAF6B-FAAA-4219-A8FF-5D154F2E3C6B,2221D884-A6F2-4121-837D-2374AC9636C0,89CFA8C9-B20F-4E9A-B5D9-54401E0A82C5,51823B1B-1738-4778-B5F7-FB7B1697B8CD,95FCD165-A509-4EF1-8D9F-C4978B388C49,8C678263-0AE6-42FB-A6A3-5EA748E5CC98,A00A4223-B447-4AE8-BF30-B07F6EBDA701,9C459468-31B5-45BF-9B7A-465C59B97AEC,F0B8C633-F051-482E-AE0E-EDDFE334071C,CB9FEB82-7605-415F-BE87-4B15D6D73E01,D6A6A67D-3E09-427A-8C8D-4D2EA824411A,2B01CF5E-71A8-41CB-8B1F-BA952B8EFFE3,9036069E-2A29-47A7-B5F2-EC7ED77EB8CC,79B12F9D-DC7B-4BF7-BCE5-8C25CF930766,9B02D04F-5733-42F0-9FF5-32E458A7D428,871FCFA9-D399-4238-928F-DF6426CE9906,A8100FC0-F44F-493F-973D-BC86C04EACD2,AB678571-1C31-40DB-9C15-4BCEBB088E30,965CB5A3-A66F-4D86-A968-34AC82C36A45,66CC027D-37F7-4C93-8083-359A970C93C5,4212A9C5-8A4C-4725-9191-751F6D6F72F5,69EEDD34-CAFE-4DD2-ACBC-9F09F4334027,35DDCE24-8EEA-48B0-AA36-B0E0E6192EBC,2E1EB7C0-1BBC-4316-ABB9-D76096A5F57F,500381E2-F096-4823-88EB-EF7BEC8156B3,2427E9BF-9274-4CC9-A07F-FC097AA733A2,746571FD-D787-46FE-BF22-590057ED48DC,302DFC4E-7557-49C6-8668-5DE8A526DFEC,8A5CF70A-E0E1-4E5F-8A40-9522448463B8,E96CCA2E-2CCE-45AC-ACB5-2F7B253B6EBC,05B7C4EA-3DEB-478B-B15C-0BC5839BB34C,32D5ADB1-4F4F-4EB2-9FEB-6F9594D33D37,431BF957-2440-456D-AF53-2A31BB18D574,265D8335-4696-44D2-928A-336A5A200721,9D04E6EE-E66D-4EF6-A4A5-B9E9C1BD275E,3E9C419F-FBBE-4428-9920-C56E3A4EA4C2,51A618C1-3569-468B-8C93-4927156BDF8E,86429C6F-7B46-46C6-A6D9-A4625202CA0A,67A5001F-8AA4-4832-A20B-F8F746E57BD5,D35AFCC4-6DC6-42D8-B4DD-630A081E794B,7D3EADFE-1AC4-4BD5-ACFF-75B29953BC12,3CC7C99D-30A8-44F6-A0B4-F1408AF728A0,655CBF46-E410-4D2B-BA49-75C75253C6B4,E8183212-E5B4-4F72-B235-88BB2507BCD5,950CDFD9-B20E-4E00-AD41-1103449856E2,766ADC5B-BF3D-4760-91E6-C11FCD90C1F9,BF509EE3-6B29-4F9E-992A-7301A6634BCC,1D5C9900-9D38-4AAB-9A34-4A031DA0D332,B984C66A-ACA6-472D-A9DA-CAB0CED70BFC,C20C499E-BD37-4741-BFAB-35C8B7DFA84C,687B0DE4-E03D-4D0C-8351-394EF9174070,F86C6FCD-C348-41C8-81A4-7E90EA7FD93F,627731AF-F058-49C1-97E8-C473471EC152'
	--SET @vids = N'D0C9D59C-0EC2-426F-AE71-66AAC60E2F77'
	--SET @status = '0,1,98'

    SET @sdate = [dbo].TZ_ToUTC(@sdate, DEFAULT, @uid)
    SET @edate = [dbo].TZ_ToUTC(@edate, DEFAULT, @uid)

	DECLARE @maxDiam FLOAT
	SELECT @maxDiam = dbo.GetUserGeoMaxDiam(@uid)
	
	DECLARE @speedmult FLOAT
	SET @speedmult = CAST([dbo].[UserPref](@uid, 208) AS FLOAT)

	DECLARE @expirycoach INT, @expirynoncoach INT
	SELECT @expirycoach = CAST(ISNULL(dbo.CustomerPref(CustomerID, 3009), 8760) AS INT), @expirynoncoach = CAST(ISNULL(dbo.CustomerPref(CustomerID, 3010), 1440) AS INT)
	FROM dbo.[User]
	WHERE UserID = @uid
	
	--Create a temporary list for the geofence that only belongs to specified customer. To prevent duplicates in the main select.
	DECLARE @geofence TABLE 
	(
		GeofenceId UNIQUEIDENTIFIER,
		Name VARCHAR(MAX),
		the_geom GEOMETRY,
		IsVideoProhibited BIT
	)

	INSERT INTO @geofence
	(
	    GeofenceId,
	    Name,
	    the_geom,
	    IsVideoProhibited
	)
	SELECT geo.GeofenceId,geo.Name,geo.the_geom,geo.IsVideoProhibited
	FROM dbo.Geofence geo
	INNER JOIN dbo.[User] u ON geo.CreationUserId = u.UserID
	INNER JOIN dbo.Customer c ON c.CustomerId = u.CustomerID
	INNER JOIN dbo.[User] cu ON cu.CustomerID = u.CustomerID
	WHERE cu.UserId = @uid
	AND geo.Archived = 0
	 
	
	SELECT	i.IncidentId,
			i.VehicleIntId,
			i.DriverIntId,
			v.VehicleId,
			v.Registration,
			v.VehicleTypeID,
			d.DriverId,
			dbo.FormatDriverNameByUser(d.DriverId, @uid) AS DriverName,
			
			--i.CreationCodeId
			CASE WHEN i.CreationCodeId = 0 AND i.ApiMetadataId IS NULL THEN 435 ELSE i.CreationCodeId END AS CreationCodeId,
			i.Long,
			i.Lat,
			[dbo].[GetGeofenceNameFromLongLat_Ltd] (i.Lat, i.Long, @uid, [dbo].[GetAddressFromLongLat](i.Lat, i.Long), @maxDiam) AS ReverseGeoCode,
			i.Heading,
			CAST(ROUND(i.Speed * @speedmult, 0) AS SMALLINT) AS Speed,
			e.OdoGPS,
			e.OdoRoadSpeed,
			e.OdoDashboard,
			dbo.TZ_GetTime(i.EventDateTime, DEFAULT, @uid) AS EventDateTime,
			e.DigitalIO,
			e.SpeedLimit,
			i.LastOperation,
			i.Archived,
			i.CustomerIntId,
			i.EventId,
			i.CoachingStatusId,
			dbo.GetPreviousCoachingStatus(i.IncidentId, i.CoachingStatusId) AS PreviousCoachingStatusId,
			c.Serial,
			
			i.ApiEventId,
			i.ApiMetadataId,
			dbo.TZ_GetOffsetInHours(@uid, i.EventDateTime) AS OffsetHours,

			--v1.VideoId AS VideoId_1,
			v1.ApiVideoId AS ApiVideoId_1,
			MAX(v1.ApiFileName) AS ApiFileName_1,
			--v1.ApiStartTime AS ApiStartTime_1,
			--v1.ApiEndTime AS ApiEndTime_1,
			dbo.TZ_GetTime(v1.ApiStartTime, DEFAULT, @uid) AS ApiStartTime_1,
			dbo.TZ_GetTime(v1.ApiEndTime, DEFAULT, @uid) AS ApiEndTime_1,
			MAX(CAST(v1.IsVideoStoredLocally AS TINYINT)) AS IsVideoStoredLocally_1,

			--v2.VideoId AS VideoId_2,
			v2.ApiVideoId AS ApiVideoId_2,
			MAX(v2.ApiFileName) AS ApiFileName_2,
			--v2.ApiStartTime AS ApiStartTime_2,
			--v2.ApiEndTime AS ApiEndTime_2,
			dbo.TZ_GetTime(v2.ApiStartTime, DEFAULT, @uid) AS ApiStartTime_2,
			dbo.TZ_GetTime(v2.ApiEndTime, DEFAULT, @uid) AS ApiEndTime_2,
			MAX(CAST(v2.IsVideoStoredLocally AS TINYINT)) AS IsVideoStoredLocally_2,
			
			p.ApiUrl,
			p.ApiUser,
			p.ApiPassword,
			p.BucketName,

			i.MaxX, i.MaxY, i.MinX, i.MinY,
			CASE WHEN MAX(os.ObjectShareId) IS NOT NULL THEN 1 ELSE 0 END AS IsEscalated,
			CASE WHEN i.CoachingStatusId IN (2,4,97) THEN
				CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) > @expirycoach THEN 'Unavailable' ELSE CASE WHEN MAX(v1.ApiFileName) = MAX(v1.ApiEventId) THEN 'S3' ELSE CASE WHEN (v1.ApiVideoId LIKE '%vtappdatalive%') THEN 'VT' ELSE CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) <= 1440 THEN 'TrajetAndRTL' ELSE 'RTL' END END END END
			ELSE	
				CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) > @expirynoncoach THEN 'Unavailable' ELSE CASE WHEN MAX(v1.ApiFileName) = MAX(v1.ApiEventId) THEN 'S3' ELSE CASE WHEN (v1.ApiVideoId LIKE '%vtappdatalive%') THEN 'VT' ELSE CASE WHEN DATEDIFF(HOUR, i.EventDateTime, GETDATE()) <= 1440 THEN 'Trajet' ELSE 'Unavailable' END END END END 
			END	AS VideoAvailability

	FROM dbo.CAM_Incident i
		LEFT OUTER JOIN dbo.ObjectShare os ON i.IncidentId = os.ObjectIntId AND os.ObjectTypeId = 1 AND os.Archived = 0
		LEFT OUTER JOIN dbo.Event e ON i.EventId = e.EventId
		INNER JOIN dbo.Driver d ON i.DriverIntId = d.DriverIntId
		INNER JOIN dbo.Vehicle v ON i.VehicleIntId = v.VehicleIntId
		INNER JOIN dbo.Customer cust ON i.CustomerIntId = cust.CustomerIntId
		INNER JOIN dbo.Camera c ON c.CameraIntId = i.CameraIntId 
		INNER JOIN dbo.Project p ON c.ProjectId = p.ProjectId
		INNER JOIN dbo.CAM_Video v1 ON i.IncidentId = v1.IncidentId AND v1.CameraNumber = 1 AND v1.VideoStatus = 1
		LEFT OUTER JOIN dbo.CAM_Video v2 ON i.IncidentId = v2.IncidentId AND v2.CameraNumber = 2 AND v2.VideoStatus = 1
		LEFT JOIN @geofence geo ON geometry::Point(i.Long,i.Lat, 4326).STWithin(geo.the_geom) = 1 
		
	WHERE v.VehicleId IN (SELECT VALUE FROM dbo.Split(@vids, ','))
		AND i.CoachingStatusId IN (SELECT CAST(VALUE AS SMALLINT) FROM dbo.Split(@status, ','))
		AND i.EventDateTime BETWEEN @sdate AND @edate
		AND i.Archived = 0
		AND i.CreationCodeId IN 
							(
							0, /* Harsh unknown */
							55,	/* Button */
							-- 455, 	/* ROP Stage 1 */
							456, 	/* ROP Stage 2 */
							436, 	/* Harsh Decel High */
							437, 	/* Harsh Accel High */
							438)	/* Harsh Corner High */
		AND (geo.IsVideoProhibited IS NULL OR geo.IsVideoProhibited = 0)
	GROUP BY i.IncidentId, i.VehicleIntId, i.DriverIntId, v.VehicleId, v.Registration, v.VehicleTypeID, d.DriverId,
		i.CreationCodeId, i.Long, i.Lat, i.Heading, i.Speed, e.OdoGPS, e.OdoRoadSpeed, e.OdoDashboard, i.EventDateTime, e.DigitalIO,
		e.SpeedLimit, i.LastOperation, i.Archived, i.CustomerIntId, i.EventId, i.CoachingStatusId, c.Serial, i.ApiEventId, i.ApiMetadataId,
		v1.ApiStartTime, v1.ApiEndTime, v1.ApiVideoId, v2.ApiVideoId, v2.ApiStartTime, v2.ApiEndTime, p.ApiUrl, p.ApiUser, p.ApiPassword,p.BucketName,
		i.MaxX, i.MaxY, i.MinX, i.MinY
	ORDER BY i.EventDateTime DESC



GO
