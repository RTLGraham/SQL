SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_ReportFuelDashboard_RS]
	(
		@gids VARCHAR(MAX),
		@sdate DATETIME,
		@edate DATETIME,
		@uid UNIQUEIDENTIFIER,
		@fuelunitcode CHAR(1) = 'L'
	)
AS
BEGIN
	SET NOCOUNT ON;
    
	--DECLARE	@gids VARCHAR(MAX),
	--	@sdate DATETIME,
	--	@edate DATETIME,
	--	@uid UNIQUEIDENTIFIER;

	--SET @gids = NULL;
	--SET @sdate = '2011-01-01 00:00:00';
	--SET @edate = '2011-12-31 23:59:59';
	--SET @uid = N'38AAFFD4-1AE7-479B-889A-4D7F52C0DB58';

	DECLARE @DataCube TABLE (
		GroupName NVARCHAR(255),
		[Month] NVARCHAR(8),
		FuelEcon FLOAT,
		FuelStr NVARCHAR(20)
	);
	
	INSERT	@DataCube(GroupName, Month, FuelEcon, FuelStr)
	EXEC	dbo.proc_ReportFuelDashboard @gids, @sdate, @edate, @uid, @fuelunitcode;
	
	SELECT	DISTINCT
		CASE G.GroupName WHEN 'Total' THEN 1 ELSE 0 END AS 'GroupID', G.GroupName, G.FuelStr, 
		YTD.FuelEcon AS YTD,
		Jan.FuelEcon AS Jan, Feb.FuelEcon AS Feb, Mar.FuelEcon AS Mar,
		Apr.FuelEcon AS Apr, May.FuelEcon AS May, Jun.FuelEcon AS Jun,
		Jul.FuelEcon AS Jul, Aug.FuelEcon AS Aug, Sep.FuelEcon AS Sep,
		Oct.FuelEcon AS Oct, Nov.FuelEcon AS Nov, Dec.FuelEcon AS Dec
		/*
		COALESCE(YTD.FuelEcon, 0) AS YTD,
		COALESCE(Jan.FuelEcon, 0) AS Jan, COALESCE(Feb.FuelEcon, 0) AS Feb, COALESCE(Mar.FuelEcon, 0) AS Mar,
		COALESCE(Apr.FuelEcon, 0) AS Apr, COALESCE(May.FuelEcon, 0) AS May, COALESCE(Jun.FuelEcon, 0) AS Jun,
		COALESCE(Jul.FuelEcon, 0) AS Jul, COALESCE(Aug.FuelEcon, 0) AS Aug, COALESCE(Sep.FuelEcon, 0) AS Sep,
		COALESCE(Oct.FuelEcon, 0) AS Oct, COALESCE(Nov.FuelEcon, 0) AS Nov, COALESCE(Dec.FuelEcon, 0) AS Dec */
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
