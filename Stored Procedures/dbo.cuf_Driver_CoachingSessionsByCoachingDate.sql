SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Driver_CoachingSessionsByCoachingDate]
(
	@uid UNIQUEIDENTIFIER,
	@dids VARCHAR(MAX),
	@sdate DATETIME,
	@edate datetime 
)
AS
	
	--DECLARE @sdate DATETIME,
	--		@edate DATETIME,
	--		@dids NVARCHAR(MAX),
	--		@uid UNIQUEIDENTIFIER

	--SELECT	@sdate = '2016-01-01 00:00',
	--		@edate = '2017-03-28 23:59',
	--		@uid = N'988D25DE-65E9-4FC5-8981-3D2B4EA0FEAB',
	--		@dids = '1CBEA472-C170-4F80-AE81-BF656A923D8F,816C71E9-BC69-4FB7-B564-79BCF49EDBB5,82E69B50-ED9A-4A4C-BAFF-BD3FA197BCF5,8C696700-FE18-46ED-90F6-0BBDBBF202C3,3DD07F07-3596-4943-A46A-CAAB8A4C5DDE,3CB4E96B-8108-4B90-93A9-264010AFC74C,4A0A1CB1-BFB8-4329-84FB-92BE98835D96,4A0A1CB1-BFB8-4329-84FB-92BE98835D96,3CB4E96B-8108-4B90-93A9-264010AFC74C,33210B81-CC0B-48FE-B3A6-F2C5C8A13825,33210B81-CC0B-48FE-B3A6-F2C5C8A13825,33210B81-CC0B-48FE-B3A6-F2C5C8A13825,875E92C2-8481-4A37-ADF5-CE6883605432,875E92C2-8481-4A37-ADF5-CE6883605432,875E92C2-8481-4A37-ADF5-CE6883605432,355BE463-63F2-4AA0-ABE3-093FFA77B259,355BE463-63F2-4AA0-ABE3-093FFA77B259,7E4E1F71-0560-4FD6-88EC-ADA78996C317,0D64DBFE-C546-4345-8E62-C653CB3B0796,0D64DBFE-C546-4345-8E62-C653CB3B0796'
	--		--@dids = '1CBEA472-C170-4F80-AE81-BF656A923D8F,816C71E9-BC69-4FB7-B564-79BCF49EDBB5,82E69B50-ED9A-4A4C-BAFF-BD3FA197BCF5'
	
	DECLARE @timediff NVARCHAR(30),
			@Culture NCHAR(5)
	SET @timediff = dbo.[UserPref](@uid, 600)
	SELECT TOP 1 @Culture = up.Value
	FROM dbo.[User] u
		INNER JOIN dbo.UserPreference up ON up.UserID = u.UserID
	WHERE u.Archived = 0 AND u.UserID = @uid AND up.NameID = 310

	SELECT 
		d.DriverId,
		g.GroupId,
		u.UserId as CoachUserId,

		g.GroupName,
		d.FirstName + ' ' + d.Surname AS DriverName, 

		u.Name AS CoachUserName, 
		u.FirstName + ' ' + u.Surname AS CoachName,
		
		dbo.[TZ_GetTime](cs.LastOperation, @timediff, @uid) AS EventTime,
		dbo.[TZ_GetTime](cs.LastOperation, @timediff, @uid) AS CoachingCompletedOn,
	
		c.Safety ,
		c.Efficiency ,
		c.FuelEcon ,

		c.CoachingSessionId,
		NULL AS IncidentId,
		97 AS WidgetType,
		'Performance' AS CoachingType,
		STUFF(ISNULL((SELECT ', ' + co2.Name
                FROM dbo.CAM_Coaching c2
					INNER JOIN dbo.CAM_CoachingSession cs2 ON cs2.CoachingSessionId = c2.CoachingSessionId
					LEFT OUTER JOIN dbo.CAM_CoachingResult cr2 ON cr2.CoachingSessionId = cs2.CoachingSessionId AND cr.Archived = 0
					LEFT OUTER JOIN dbo.CAM_CoachingOutcome co2 ON co2.CoachingOutcomeId = cr2.CoachingOutcomeId AND co.Archived = 0
					LEFT OUTER JOIN dbo.CAM_CoachingOutcomeTranslation cst2 ON cst2.CoachingOutcomeId = co2.CoachingOutcomeId AND cst2.LanguageCulture IS NULL AND cst2.Archived = 0
               WHERE c2.CoachingId = c.CoachingId
               GROUP BY co2.Name
             FOR XML PATH (''), TYPE).value('.','VARCHAR(max)'), ''), 1, 2, '') AS ExtraData
	FROM dbo.CAM_Coaching c
		INNER JOIN dbo.CAM_CoachingSession cs ON cs.CoachingSessionId = c.CoachingSessionId
		LEFT OUTER JOIN dbo.CAM_CoachingResult cr ON cr.CoachingSessionId = cs.CoachingSessionId AND cr.Archived = 0
		LEFT OUTER JOIN dbo.CAM_CoachingOutcome co ON co.CoachingOutcomeId = cr.CoachingOutcomeId AND co.Archived = 0
		LEFT OUTER JOIN dbo.CAM_CoachingOutcomeTranslation cst ON cst.CoachingOutcomeId = co.CoachingOutcomeId AND cst.LanguageCulture IS NULL AND cst.Archived = 0
		INNER JOIN dbo.Driver d ON cs.CoachedDriverId = d.DriverId
		INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = d.DriverId
		INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
		INNER JOIN dbo.[User] u ON cs.CoachUserId = u.UserID
		INNER JOIN dbo.Customer cust ON u.CustomerID = cust.CustomerId
	WHERE 
		cs.CoachingStatusId = 2 
		AND c.DriverId IN (SELECT Value FROM dbo.Split(@dids, ',')) 
		AND c.PeriodNum IS NULL
		AND cs.Archived = 0
		AND g.IsParameter = 0 AND g.Archived = 0 AND g.GroupTypeId = 2
		AND cs.LastOperation BETWEEN @sdate AND @edate
		
	UNION ALL

	SELECT	d.DriverId,
			g.GroupId,
			u.UserId as CoachUserId,

			g.GroupName,
			d.FirstName + ' ' + d.Surname AS DriverName, 

			u.Name AS CoachUserName, 
			u.FirstName + ' ' + u.Surname AS CoachName,
			
			dbo.[TZ_GetTime](i.EventDateTime, @timediff, @uid) AS EventTime,
			dbo.[TZ_GetTime](hist.StatusDateTime, @timediff, @uid) AS CoachingCompletedOn,

			0.0 AS Safety ,
			0.0 AS Efficiency ,
			0.0 AS FuelEcon ,

			NULL AS CoachingSessionId,
			i.IncidentId,
			95 AS WidgetType,
			'Event' AS CoachingType,
			STUFF(ISNULL((SELECT ', ' + tt2.DisplayName
                FROM dbo.CAM_Incident i2
					INNER JOIN dbo.CAM_IncidentTag it2 ON it2.IncidentId = i2.IncidentId AND it2.Archived = 0
					INNER JOIN dbo.CAM_Tag t2 ON t2.TagId = it2.TagId
					INNER JOIN dbo.CAM_TagTranslation tt2 ON tt2.TagId = t2.TagId AND ISNULL(tt2.LanguageCulture, 'en-GB') = @Culture
				WHERE i2.IncidentId = i.IncidentId AND t2.TagTypeId IN (0,1,2,4,5,6) AND t2.Archived = 0 AND tt2.Archived = 0
               GROUP BY tt2.DisplayName
             FOR XML PATH (''), TYPE).value('.','VARCHAR(max)'), ''), 1, 2, '') AS ExtraData
	FROM dbo.CAM_Incident i
		INNER JOIN dbo.Driver d ON d.DriverIntId = i.DriverIntId
		INNER JOIN dbo.CreationCode cc ON cc.CreationCodeId = i.CreationCodeId
		INNER JOIN dbo.CoachingStatusType cst ON i.CoachingStatusId = cst.CoachingStatusTypeId
		INNER JOIN dbo.VideoCoachingHistory hist ON hist.IncidentId = i.IncidentId AND i.CoachingStatusId = hist.CoachingStatusId
		INNER JOIN dbo.[User] u ON hist.StatusUserId = u.UserID
		INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = d.DriverId
		INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId AND g.GroupTypeId = 2
	WHERE d.DriverId IN (SELECT Value FROM dbo.Split(@dids, ',')) 
		AND i.CoachingStatusId = 4
		--AND i.CoachingStatusId IN
		--(
		--	1,	-- for review
		--	97, -- positive recognition
		--	4,	-- coached
		--	3	-- caching not required
		--)
		--AND i.EventDateTime BETWEEN @sdate AND @edate
		AND hist.LastOperation BETWEEN @sdate AND @edate
		AND i.Archived = 0
		AND i.CreationCodeId IN (436, 437, 438, 455, 456)
		AND g.GroupTypeId = 2 AND g.IsParameter = 0 AND g.Archived = 0

	ORDER BY CoachingCompletedOn DESC

GO
