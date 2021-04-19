SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ReportFuelEfficiencySafetyDashboard_RS]
	(
		@gids VARCHAR(MAX),
		@sdate DATETIME,
		@edate DATETIME,
		@uid UNIQUEIDENTIFIER,
		@rprtcfgid UNIQUEIDENTIFIER
	)
AS
BEGIN

	-- Note that the date parameters are redundant in this script as the report is a YTD report
	-- The start date will be set to the 1st Jan for current year
	-- The end date will be set to yesterday
	-- These date changes are performed in the main stored proc which is called below
	SET NOCOUNT ON;
    
--	DECLARE	@gids VARCHAR(MAX),
--		@sdate DATETIME,
--		@edate DATETIME,
--		@uid UNIQUEIDENTIFIER,
--		@rprtcfgid UNIQUEIDENTIFIER;
--
--	SET @gids = N'C06FFFFC-ABBE-4A6D-9E12-94469E725285';
--	SET @sdate = '2012-01-01 00:00:00';
--	SET @edate = '2012-08-31 23:59:59';
--	SET @uid = N'DC29EE2F-2F71-475D-94E1-87C95C05EF7C';
--	SET @rprtcfgid = N'77C80BDB-5827-4C5E-BBF4-06F36ACB47D6';

	DECLARE @DataCube TABLE (
		GroupName NVARCHAR(255),
		[Month] NVARCHAR(8),
		FuelEcon FLOAT,
		FuelStr NVARCHAR(20),
		SafetyScore FLOAT,
		EfficiencyScore FLOAT
	);
	
	INSERT	@DataCube(GroupName, Month, FuelEcon, FuelStr, SafetyScore, EfficiencyScore)
	EXEC	dbo.proc_ReportFuelEfficiencySafetyDashboard @gids, @sdate, @edate, @uid, @rprtcfgid;
	
	SELECT	DISTINCT
		CASE G.GroupName WHEN 'Total' THEN 1 ELSE 0 END AS 'GroupID', G.GroupName, G.FuelStr, 
		YTD.FuelEcon AS YTD, YTD.SafetyScore AS YTDSafety, YTD.EfficiencyScore AS YTDEfficiency,
		Jan.FuelEcon AS Jan, Jan.SafetyScore AS JanSafety, Jan.EfficiencyScore AS JanEfficiency,
		Feb.FuelEcon AS Feb, Feb.SafetyScore AS FebSafety, Feb.EfficiencyScore AS FebEfficiency,
		Mar.FuelEcon AS Mar, Mar.SafetyScore AS MarSafety, Mar.EfficiencyScore AS MarEfficiency,
		Apr.FuelEcon AS Apr, Apr.SafetyScore AS AprSafety, Apr.EfficiencyScore AS AprEfficiency,
		May.FuelEcon AS May, May.SafetyScore AS MaySafety, May.EfficiencyScore AS MayEfficiency,
		Jun.FuelEcon AS Jun, Jun.SafetyScore AS JunSafety, Jun.EfficiencyScore AS JunEfficiency,
		Jul.FuelEcon AS Jul, Jul.SafetyScore AS JulSafety, Jul.EfficiencyScore AS JulEfficiency,
		Aug.FuelEcon AS Aug, Aug.SafetyScore AS AugSafety, Aug.EfficiencyScore AS AugEfficiency,
		Sep.FuelEcon AS Sep, Sep.SafetyScore AS SepSafety, Sep.EfficiencyScore AS SepEfficiency,
		Oct.FuelEcon AS Oct, Oct.SafetyScore AS OctSafety, Oct.EfficiencyScore AS OctEfficiency,
		Nov.FuelEcon AS Nov, Nov.SafetyScore AS NovSafety, Nov.EfficiencyScore AS NovEfficiency,
		Dec.FuelEcon AS Dec, Dec.SafetyScore AS DecSafety, Dec.EfficiencyScore AS DecEfficiency

	FROM	@DataCube G
		LEFT OUTER JOIN @DataCube Jan ON G.GroupName = Jan.GroupName AND RIGHT(Jan.Month, 2) = '01'
		LEFT OUTER JOIN @DataCube Feb ON G.GroupName = Feb.GroupName AND RIGHT(Feb.Month, 2) = '02'
		LEFT OUTER JOIN @DataCube Mar ON G.GroupName = Mar.GroupName AND RIGHT(Mar.Month, 2) = '03'
		LEFT OUTER JOIN @DataCube Apr ON G.GroupName = Apr.GroupName AND RIGHT(Apr.Month, 2) = '04'
		LEFT OUTER JOIN @DataCube May ON G.GroupName = May.GroupName AND RIGHT(May.Month, 2) = '05'
		LEFT OUTER JOIN @DataCube Jun ON G.GroupName = Jun.GroupName AND RIGHT(Jun.Month, 2) = '06'
		LEFT OUTER JOIN @DataCube Jul ON G.GroupName = Jul.GroupName AND RIGHT(Jul.Month, 2) = '07'
		LEFT OUTER JOIN @DataCube Aug ON G.GroupName = Aug.GroupName AND RIGHT(Aug.Month, 2) = '08'
		LEFT OUTER JOIN @DataCube Sep ON G.GroupName = Sep.GroupName AND RIGHT(Sep.Month, 2) = '09'
		LEFT OUTER JOIN @DataCube Oct ON G.GroupName = Oct.GroupName AND RIGHT(Oct.Month, 2) = '10'
		LEFT OUTER JOIN @DataCube Nov ON G.GroupName = Nov.GroupName AND RIGHT(Nov.Month, 2) = '11'
		LEFT OUTER JOIN @DataCube Dec ON G.GroupName = Dec.GroupName AND RIGHT(Dec.Month, 2) = '12'
		LEFT OUTER JOIN @DataCube YTD ON G.GroupName = YTD.GroupName AND YTD.Month = 'YTD'
	ORDER BY	1, G.GroupName;
END;

GO
