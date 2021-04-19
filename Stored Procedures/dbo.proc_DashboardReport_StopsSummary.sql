SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_DashboardReport_StopsSummary]
          @uid      uniqueidentifier,
          @vids     nvarchar(MAX),
          @gids     nvarchar(MAX),
          @sdate    datetime,
          @edate    DATETIME,
          @InOut	SMALLINT
AS

--	DECLARE @luid UNIQUEIDENTIFIER,
--			@lvids NVARCHAR(MAX),
--			@lgids NVARCHAR(MAX),
--			@lsdate DATETIME,
--			@ledate DATETIME,
--			@lInOut SMALLINT
--					
--	SET @luid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--	SET @lvids = N'5AAB0E74-D39E-483B-AAFF-200FB5A56850,1860348D-20B5-42CF-BA66-203864BA0461,BD5F9889-8007-4943-9001-46CB3ED2D36F,4DA5FA6D-8496-4D75-AA6A-4C32B377BDF9,C5868274-5850-4762-8EA8-5B5B7C1C2B5B,BD15D85F-F591-4AB5-881A-65E296715D18,33A67A70-9935-4214-B7B0-69B7AC228F5C,46F9F76A-1324-474B-B0BD-6E160C3E8ACD,EB5F8AE0-FC95-4D38-87FE-801C22911CA6,2D68CB77-FE15-4030-839A-824B6D0806BA,9A615ECD-2389-4D20-B0BE-8667626A38BA,CF6E7729-C9E7-4373-BEAB-895D9A2F1379,8288801A-186F-4BE4-A044-8A4007BD2372,0BBEF81F-92A9-4183-A354-8B15F4B354DD,AE9AD52F-7659-4339-BB56-A39AC3923A54,DF0D3E78-19EB-4779-BAE8-A974FE4F1B33,F5F18987-540E-44A0-A9EB-BC42699EFA30,2E7A5E82-702A-4003-BB17-C072A93ED941,18750389-36C6-4D3E-BE79-C54B859CE83B,2C63EBDD-07D4-4F26-A3A4-C5E18DBCB5CF,0A293ED6-5DE5-4B92-BDF0-C8357DF9003D,D103A123-A2A2-4EF1-97DF-D184E971FE7B,C98B01D1-B2E7-4378-A1A4-D5245CDDDF0D,3AAEA81D-20C4-4F24-B022-DECA9C7C51B1,5081472D-203E-4F21-9CF8-E1F98619361A'
--	SET @lgids = N'2FA7D5A1-D308-4444-9DE3-9538BA2DAB30,A5ECBA13-F1BD-4B7C-BA52-09CB3107A26A'
--	SET @ledate = '2013-01-10 23:59'
--	SET @lsdate = DATEADD(dd, -7, @ledate)
--	SET @lInOut = 0
	
DECLARE   @luid      uniqueidentifier,
          @lvids     nvarchar(MAX),
          @lgids     nvarchar(MAX),
          @lsdate    datetime,
          @ledate    DATETIME,
          @lInOut	SMALLINT
          
    SET @luid = @uid
    SET @lvids = @vids
    SET @lgids = @gids
    SET @lsdate = @sdate
    SET @ledate = @edate
    SET @lInOut = @InOut
	
	SET @lsdate = dbo.TZ_ToUtc(@lsdate, DEFAULT, @luid)
	SET @ledate = dbo.TZ_ToUtc(@ledate, DEFAULT, @luid)
 
	IF @lInOut > 0
	BEGIN                   
		SELECT g.GroupId, ISNULL(g.GroupName, 'Unknown') AS GroupName, COUNT(*) AS StopCount
		FROM dbo.Event e
		INNER JOIN dbo.Customer c ON e.CustomerIntId = c.CustomerIntId
		LEFT JOIN dbo.WorkingHours w ON c.CustomerId = w.CustomerID
		LEFT JOIN dbo.VehicleGeofenceHistory vgh ON e.VehicleIntId = vgh.VehicleIntId AND e.EventDateTime BETWEEN vgh.EntryDateTime AND vgh.ExitDateTime
		LEFT JOIN dbo.GroupDetail gd ON vgh.GeofenceId = gd.EntityDataId
		LEFT JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
		INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
		WHERE v.VehicleId IN (SELECT VALUE FROM dbo.Split(@lvids, ','))
		  AND (g.GroupId IN (SELECT VALUE FROM dbo.Split(@lgids, ',')) OR g.GroupId IS NULL)
		  AND e.EventDateTime BETWEEN @lsdate AND @ledate
		  AND e.CreationCodeId = 5  
		  AND  (DATEPART(dw, e.EventDateTime) = 1 -- Sunday
				AND (DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, SunStart), SunStart), '00:00:00')
							AND DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, SunEnd), SunEnd), '23:59:00'))
			OR	DATEPART(dw, e.EventDateTime) = 2 -- Monday
				AND (DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, MonStart), MonStart), '00:00:00')
							AND DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, MonEnd), MonEnd), '23:59:00'))
			OR 	DATEPART(dw, e.EventDateTime) = 3 -- Tuesday
				AND (DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, TueStart), TueStart), '00:00:00')
							AND DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, TueEnd), TueEnd), '23:59:00'))
			OR 	DATEPART(dw, e.EventDateTime) = 4 -- Wednesday
				AND (DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, WedStart), WedStart), '00:00:00')
							AND DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, WedEnd), WedEnd), '23:59:00'))
			OR	DATEPART(dw, e.EventDateTime) = 5 -- Thursday
				AND (DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, ThuStart), ThuStart), '00:00:00')
							AND DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, ThuEnd), ThuEnd), '23:59:00'))
			OR	DATEPART(dw, e.EventDateTime) = 6 -- Friday
				AND (DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, FriStart), FriStart), '00:00:00')
							AND DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, FriEnd), FriEnd), '23:59:00'))
			OR	DATEPART(dw, e.EventDateTime) = 7 -- Saturday
				AND (DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, SatStart), SatStart), '00:00:00')
							AND DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, SatEnd), SatEnd), '23:59:00'))	
			   )
 		GROUP BY g.GroupId, g.GroupName
		ORDER BY COUNT(*) DESC
	END ELSE
	IF @lInOut < 0
	BEGIN
		SELECT g.GroupId, ISNULL(g.GroupName, 'Unknown') AS GroupName, COUNT(*) AS StopCount
		FROM dbo.Event e
		INNER JOIN dbo.Customer c ON e.CustomerIntId = c.CustomerIntId
		LEFT JOIN dbo.WorkingHours w ON c.CustomerId = w.CustomerID
		LEFT JOIN dbo.VehicleGeofenceHistory vgh ON e.VehicleIntId = vgh.VehicleIntId AND e.EventDateTime BETWEEN vgh.EntryDateTime AND vgh.ExitDateTime
		LEFT JOIN dbo.GroupDetail gd ON vgh.GeofenceId = gd.EntityDataId
		LEFT JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
		INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
		WHERE v.VehicleId IN (SELECT VALUE FROM dbo.Split(@lvids, ','))
		  AND (g.GroupId IN (SELECT VALUE FROM dbo.Split(@lgids, ',')) OR g.GroupId IS NULL)
		  AND e.EventDateTime BETWEEN @lsdate AND @ledate
		  AND e.CreationCodeId = 5  
		  AND  (DATEPART(dw, e.EventDateTime) = 1 -- Sunday
				AND (DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, SunStart), SunStart), '23:59:00')
							OR DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, SunEnd), SunEnd), '00:00:00'))
			OR	DATEPART(dw, e.EventDateTime) = 2 -- Monday
				AND (DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, MonStart), MonStart), '23:59:00')
							OR DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, MonEnd), MonEnd), '00:00:00'))
			OR 	DATEPART(dw, e.EventDateTime) = 3 -- Tuesday
				AND (DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, TueStart), TueStart), '23:59:00')
							OR DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, TueEnd), TueEnd), '00:00:00'))
			OR 	DATEPART(dw, e.EventDateTime) = 4 -- Wednesday
				AND (DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, WedStart), WedStart), '23:59:00')
							OR DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, WedEnd), WedEnd), '00:00:00'))
			OR	DATEPART(dw, e.EventDateTime) = 5 -- Thursday
				AND (DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, ThuStart), ThuStart), '23:59:00')
							OR DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, ThuEnd), ThuEnd), '00:00:00'))
			OR	DATEPART(dw, e.EventDateTime) = 6 -- Friday
				AND (DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, FriStart), FriStart), '23:59:00')
							OR DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, FriEnd), FriEnd), '00:00:00'))
			OR	DATEPART(dw, e.EventDateTime) = 7 -- Saturday
				AND (DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) < ISNULL(DATEADD(day, -DATEDIFF(day, 0, SatStart), SatStart), '23:59:00')
							OR DATEADD(day, -DATEDIFF(day, 0, e.EventDateTime), e.EventDateTime) > ISNULL(DATEADD(day, -DATEDIFF(day, 0, SatEnd), SatEnd), '00:00:00'))	
			   )
 		GROUP BY g.GroupId, g.GroupName
		ORDER BY COUNT(*) DESC
 	END ELSE
 	BEGIN
		SELECT g.GroupId, ISNULL(g.GroupName, 'Unknown') AS GroupName, COUNT(*) AS StopCount
		FROM dbo.Event e
		INNER JOIN dbo.Customer c ON e.CustomerIntId = c.CustomerIntId
		LEFT JOIN dbo.WorkingHours w ON c.CustomerId = w.CustomerID
		LEFT JOIN dbo.VehicleGeofenceHistory vgh ON e.VehicleIntId = vgh.VehicleIntId AND e.EventDateTime BETWEEN vgh.EntryDateTime AND vgh.ExitDateTime
		LEFT JOIN dbo.GroupDetail gd ON vgh.GeofenceId = gd.EntityDataId
		LEFT JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
		INNER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
		WHERE v.VehicleId IN (SELECT VALUE FROM dbo.Split(@lvids, ','))
		  AND (g.GroupId IN (SELECT VALUE FROM dbo.Split(@lgids, ',')) OR g.GroupId IS NULL)
		  AND e.EventDateTime BETWEEN @lsdate AND @ledate
		  AND e.CreationCodeId = 5
		GROUP BY g.GroupId, g.GroupName 
		ORDER BY COUNT(*) DESC
	END 


GO
