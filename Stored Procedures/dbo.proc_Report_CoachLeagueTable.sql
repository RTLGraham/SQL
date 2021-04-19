SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_Report_CoachLeagueTable]
(
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @uid UNIQUEIDENTIFIER
--SET @uid = N'46CB6360-855C-43F2-8C90-8528995943D1'

	DECLARE @sdate DATETIME,
			@edate DATETIME,
			@today DATETIME,
			@reportConfigId UNIQUEIDENTIFIER,
			@customerName NVARCHAR(MAX)
		
	SET @today = GETUTCDATE()
	SET @sdate = DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)
	SET @edate = DATEADD(SECOND, -1, DATEADD(month, 1, @sdate))

	--or shall we get it from the user preferences?
	SELECT @reportConfigId = cp.Value
	FROM dbo.CustomerPreference cp
		INNER JOIN dbo.Customer c ON c.CustomerId = cp.CustomerID
		INNER JOIN dbo.[User] u ON u.CustomerID = c.CustomerId
	WHERE u.UserID = @uid
		AND cp.NameID = 3002 -- Driver Individual Report Config

	SELECT @customerName = c.Name
	FROM dbo.Customer c
		INNER JOIN dbo.[User] u ON u.CustomerID = c.CustomerId
	WHERE u.UserID = @uid

	DECLARE @vIdsToExclude NVARCHAR(MAX)
	SET @vIdsToExclude = CAST(NEWID() AS NVARCHAR(MAX))

	DECLARE @coaches TABLE
	(
		CoachId UNIQUEIDENTIFIER,
		CoachName NVARCHAR(MAX),
		GroupIds NVARCHAR(MAX),
		SafetyScore FLOAT,
		EfficiencyScore FLOAT
	)

	INSERT INTO @coaches ( CoachId, CoachName)
	SELECT DISTINCT u.UserID, LTRIM(RTRIM(ISNULL(u.FirstName, '') + ' ' + ISNULL(u.Surname, ''))) AS CoachName
	FROM dbo.TAN_Trigger t
		INNER JOIN dbo.TAN_TriggerEntity te ON te.TriggerId = t.TriggerId
		INNER JOIN dbo.Vehicle v ON te.TriggerEntityId = v.VehicleId
		INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
		INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId AND g.IsParameter = 0 AND g.Archived = 0 AND g.GroupTypeId = 1
			AND g.GroupName NOT LIKE '%*%' 
			AND g.GroupName NOT LIKE '%Manage%' 
			AND g.GroupName NOT LIKE '%Phil%'
			AND g.GroupName NOT LIKE '%Temporary%'
			AND g.GroupName NOT LIKE '%$%'
		LEFT OUTER JOIN dbo.TAN_NotificationTemplate nt ON nt.TriggerId = t.TriggerId AND nt.Archived = 0 AND nt.Disabled = 0
		LEFT OUTER JOIN dbo.TAN_RecipientNotification rn ON rn.NotificationTemplateId = nt.NotificationTemplateId AND rn.Archived = 0
		LEFT OUTER JOIN dbo.[User] u ON rn.RecipientAddress = u.Email
			AND u.Name NOT IN ('COONEYSCopy')
		INNER JOIN dbo.TAN_TriggerType tt ON tt.TriggerTypeId = t.TriggerTypeId
		INNER JOIN dbo.Customer c ON c.CustomerId = t.CustomerId
	WHERE c.Name = 'Air Products'
		AND t.TriggerTypeId = 48
		AND t.Archived = 0
		AND t.Disabled = 0
		AND t.Name LIKE '-%'
		AND (rn.RecipientAddress IS NULL OR rn.RecipientAddress NOT IN ('HALLGI@airproducts.com'))

	DECLARE @report TABLE (	GroupIds NVARCHAR(MAX), TotalDrivingDistance FLOAT, 
							Efficiency FLOAT, SweetSpot FLOAT, OverRev FLOAT, Idle FLOAT, FuelEcon FLOAT,
							Safety FLOAT, OverSpeed FLOAT, Rop FLOAT, Rop2 FLOAT, Low FLOAT, Med FLOAT, Acceleration FLOAT, Braking FLOAT, Cornering FLOAT,
							sdate DATETIME, edate DATETIME,
							EfficiencyColour NVARCHAR(MAX),
							SweetSpotColour NVARCHAR(MAX),
							OverRevWithFuelColour NVARCHAR(MAX),
							IdleColour NVARCHAR(MAX),
							SafetyColour NVARCHAR(MAX),
							OverSpeedColour NVARCHAR(MAX), 
							OverSpeedDistanceColour NVARCHAR(MAX),
							RopColour NVARCHAR(MAX),
							Rop2Colour NVARCHAR(MAX),
							ManoeuvresLowColour NVARCHAR(MAX),
							ManoeuvresMedColour NVARCHAR(MAX),
							AccelerationHighColour NVARCHAR(MAX),
							BrakingHighColour NVARCHAR(MAX),
							CorneringHighColour NVARCHAR(MAX))

	DECLARE coach_cur CURSOR FAST_FORWARD FOR
	SELECT CoachId FROM @coaches

	DECLARE @coachId UNIQUEIDENTIFIER,
			@groups NVARCHAR(MAX),
			@safety FLOAT,
			@efficiency FLOAT

	OPEN coach_cur
	FETCH NEXT FROM coach_cur INTO @coachId
	WHILE @@fetch_status = 0
	BEGIN
		SELECT @groups = NULL, @safety = NULL, @efficiency = NULL
		DELETE FROM @report

		SELECT @groups = COALESCE(@groups + ',', '') + CAST(g.GroupId AS NVARCHAR(MAX))
		FROM dbo.[Group] g
			INNER JOIN dbo.UserGroup ug ON ug.GroupId = g.GroupId
		WHERE ug.UserId = @coachId AND g.GroupTypeId = 1 AND g.IsParameter = 0 AND g.Archived = 0

	
		INSERT INTO @report
		EXECUTE dbo.zzremove_AirProductsSafety_Groups @groups, @sdate, @edate, @uid, @reportConfigId, @vIdsToExclude


		SELECT @safety = r.Safety, @efficiency = r.Efficiency
		FROM @report r

		UPDATE @coaches 
		SET GroupIds = @groups,
			SafetyScore = @safety,
			EfficiencyScore = @efficiency
		WHERE CoachId = @coachId

		FETCH NEXT FROM coach_cur INTO @coachId
	END
	CLOSE coach_cur
	DEALLOCATE coach_cur

	DECLARE @totals TABLE (	GroupIds NVARCHAR(MAX), GroupNames NVARCHAR(MAX), TotalDrivingDistance FLOAT, 
							Efficiency FLOAT, SweetSpot FLOAT, OverRev FLOAT, Idle FLOAT, FuelEcon FLOAT,
							Safety FLOAT, OverSpeed FLOAT, Rop FLOAT, Rop2 FLOAT, Low FLOAT, Med FLOAT, Acceleration FLOAT, Braking FLOAT, Cornering FLOAT,
							sdate DATETIME, edate DATETIME,
							EfficiencyColour NVARCHAR(MAX),
							SweetSpotColour NVARCHAR(MAX),
							OverRevWithFuelColour NVARCHAR(MAX),
							IdleColour NVARCHAR(MAX),
							SafetyColour NVARCHAR(MAX),
							OverSpeedColour NVARCHAR(MAX), 
							OverSpeedDistanceColour NVARCHAR(MAX),
							RopColour NVARCHAR(MAX),
							Rop2Colour NVARCHAR(MAX),
							ManoeuvresLowColour NVARCHAR(MAX),
							ManoeuvresMedColour NVARCHAR(MAX),
							AccelerationHighColour NVARCHAR(MAX),
							BrakingHighColour NVARCHAR(MAX),
							CorneringHighColour NVARCHAR(MAX))


	INSERT INTO @totals
	EXECUTE dbo.zzremove_AirProductsSafety_Fleet @sdate, @edate, @uid,  @reportConfigId, @vIdsToExclude

	INSERT INTO @coaches
			( CoachId ,
			  CoachName ,
			  GroupIds ,
			  SafetyScore ,
			  EfficiencyScore
			)
	SELECT  NULL,
			@customerName,
			NULL,
			Safety,
			Efficiency
	FROM @totals

	SELECT CASE WHEN CoachId = @uid THEN 1 ELSE 0 END AS IsMe,
		   CoachId ,
		   CoachName ,

		   SafetyScore ,
		   ROW_NUMBER() OVER (ORDER BY SafetyScore DESC) AS SafetyPosition,
		   0 AS SafetyProgress,

		   EfficiencyScore,
		   ROW_NUMBER() OVER (ORDER BY EfficiencyScore DESC) AS EfficiencyPosition,
		   0 AS EfficiencyProgress,
	   
		   0.0 AS TemperatureScore,
		   0 AS TemperatureProgress,
		   0 AS TemperaturePosition,

		   @sdate AS StartDate,
		   @edate AS EndDate,
		   'This Month' AS PeriodText

	FROM @coaches


GO
