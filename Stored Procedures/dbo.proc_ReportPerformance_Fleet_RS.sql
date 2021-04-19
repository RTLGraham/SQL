SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dmitrijs Jurins>
-- Create date: <2011-07-25>
-- Description:	<National Performance Report DataView>
-- =============================================
CREATE PROCEDURE [dbo].[proc_ReportPerformance_Fleet_RS]
	@uid UNIQUEIDENTIFIER,
	@configid UNIQUEIDENTIFIER,
	@isDriver BIT
AS
BEGIN
--	DECLARE @uid UNIQUEIDENTIFIER,
--			@configid UNIQUEIDENTIFIER,
--			@isDriver BIT
--	SET @isDriver = 1
--	SET @uid = N'38AAFFD4-1AE7-479B-889A-4D7F52C0DB58'
--	SET @configid = N'3FED49AA-15C3-4875-A980-D252A6DAEF80'
	
	DECLARE @gtypeid INT,
			@diststr NVARCHAR(MAX)
	
	SELECT @diststr = [dbo].UserPref(@uid, 203)
	
	IF @isDriver = 1
	BEGIN
		SET @gtypeid = 2
	END
	ELSE 
	BEGIN 
		SET @gtypeid = 1
	END
	DECLARE @results TABLE(GroupId UNIQUEIDENTIFIER, GroupName NVARCHAR(MAX), Distance FLOAT, ScorePeriod1 FLOAT, IsScoreBetterPeriod1 BIT, ScorePeriodDate1 NVARCHAR(MAX), ScorePeriod2 FLOAT, IsScoreBetterPeriod2 BIT, ScorePeriodDate2 NVARCHAR(MAX), ScorePeriod3 FLOAT, IsScoreBetterPeriod3 BIT, ScorePeriodDate3 NVARCHAR(MAX), ScorePeriod4 FLOAT, IsScoreBetterPeriod4 BIT, ScorePeriodDate4 NVARCHAR(MAX), ScorePeriodColour1 NVARCHAR(MAX), ScorePeriodColour2 NVARCHAR(MAX), ScorePeriodColour3 NVARCHAR(MAX), ScorePeriodColour4 NVARCHAR(MAX), sdate DATETIME, edate DATETIME, CreationDateTime DATETIME, ClosureDateTime DATETIME)
	
	INSERT INTO @results( GroupId ,GroupName ,Distance ,ScorePeriod1 ,IsScoreBetterPeriod1, ScorePeriodDate1 ,ScorePeriod2 ,IsScoreBetterPeriod2 ,ScorePeriodDate2 ,ScorePeriod3 ,IsScoreBetterPeriod3 ,ScorePeriodDate3 ,ScorePeriod4 ,IsScoreBetterPeriod4 ,ScorePeriodDate4 ,ScorePeriodColour1 ,ScorePeriodColour2 ,ScorePeriodColour3 ,ScorePeriodColour4, sdate, edate, CreationDateTime, ClosureDateTime)
	EXECUTE [dbo].[proc_ReportPerformance_Fleet] @gtypeid,@uid,@configid
	
--	SELECT * FROM @results
	SELECT 
		r2.GroupId,
		r2.GroupName,
		r2.ScorePeriodDate2,
						
		r2.Distance,
		r2.ScorePeriod1,
		r2.IsScoreBetterPeriod1,
		CASE WHEN r2.ScorePeriodDate1 IS NOT NULL AND LEN(r2.ScorePeriodDate1) = 6
			THEN SUBSTRING(DATENAME( month , DateAdd( month , CAST(SUBSTRING(r2.ScorePeriodDate1, 5, 2) AS INT) , 0 ) - 1 ), 0, 4)
			ELSE 'N/A' END AS ScorePeriodDate1,
		r2.ScorePeriod2,
		r2.IsScoreBetterPeriod2,
		CASE WHEN r2.ScorePeriodDate2 IS NOT NULL AND LEN(r2.ScorePeriodDate2) = 6
			THEN SUBSTRING(DATENAME( month , DateAdd( month , CAST(SUBSTRING(r2.ScorePeriodDate2, 5, 2) AS INT) , 0 ) - 1 ), 0, 4)
			ELSE 'N/A' END AS ScorePeriodDate2,
		r2.ScorePeriod3,
		r2.IsScoreBetterPeriod3,
		CASE WHEN r2.ScorePeriodDate3 IS NOT NULL AND LEN(r2.ScorePeriodDate3) = 6
			THEN SUBSTRING(DATENAME( month , DateAdd( month , CAST(SUBSTRING(r2.ScorePeriodDate3, 5, 2) AS INT) , 0 ) - 1 ), 0, 4)
			ELSE 'N/A' END AS ScorePeriodDate3,
		r2.ScorePeriod4,
		r2.IsScoreBetterPeriod4,
		CASE WHEN r2.ScorePeriodDate4 IS NOT NULL AND LEN(r2.ScorePeriodDate4) = 6
			THEN SUBSTRING(DATENAME( month , DateAdd( month , CAST(SUBSTRING(r2.ScorePeriodDate4, 5, 2) AS INT) , 0 ) - 1 ), 0, 4)
			ELSE 'N/A' END AS ScorePeriodDate4,
		r2.ScorePeriodColour1,
		r2.ScorePeriodColour2,
		r2.ScorePeriodColour3,
		r2.ScorePeriodColour4,
		
		r3.Distance AS TotalDistance,
		r3.ScorePeriod1 AS TotalScorePeriod1,
		CASE WHEN r3.ScorePeriodDate1 IS NOT NULL AND LEN(r3.ScorePeriodDate1) = 6
			THEN SUBSTRING(DATENAME( month , DateAdd( month , CAST(SUBSTRING(r3.ScorePeriodDate1, 5, 2) AS INT) , 0 ) - 1 ), 0, 4)
			ELSE 'N/A' END AS TotalScorePeriodDate1,
		r3.ScorePeriod2 AS TotalScorePeriod2,
		CASE WHEN r3.ScorePeriodDate2 IS NOT NULL AND LEN(r3.ScorePeriodDate2) = 6
			THEN SUBSTRING(DATENAME( month , DateAdd( month , CAST(SUBSTRING(r3.ScorePeriodDate2, 5, 2) AS INT) , 0 ) - 1 ), 0, 4)
			ELSE 'N/A' END AS TotalScorePeriodDate2,
		r3.ScorePeriod3 AS TotalScorePeriod3,
		CASE WHEN r3.ScorePeriodDate3 IS NOT NULL AND LEN(r3.ScorePeriodDate3) = 6
			THEN SUBSTRING(DATENAME( month , DateAdd( month , CAST(SUBSTRING(r3.ScorePeriodDate3, 5, 2) AS INT) , 0 ) - 1 ), 0, 4)
			ELSE 'N/A' END AS TotalScorePeriodDate3,
		r3.ScorePeriod4 AS TotalScorePeriod4,
		CASE WHEN r3.ScorePeriodDate4 IS NOT NULL AND LEN(r3.ScorePeriodDate4) = 6
			THEN SUBSTRING(DATENAME( month , DateAdd( month , CAST(SUBSTRING(r3.ScorePeriodDate4, 5, 2) AS INT) , 0 ) - 1 ), 0, 4)
			ELSE 'N/A' END AS TotalScorePeriodDate4,
		r3.ScorePeriodColour1 AS TotalScorePeriodColour1,
		r3.ScorePeriodColour2 AS TotalScorePeriodColour2,
		r3.ScorePeriodColour3 AS TotalScorePeriodColour3,
		r3.ScorePeriodColour4 AS TotalScorePeriodColour4,
		
		@diststr AS DistanceUnit
	FROM @results r2
		INNER JOIN @results r3 ON r3.GroupId IS NULL
	WHERE r2.GroupId IS NOT NULL
	ORDER BY r2.ScorePeriod4 ASC
	
END

GO
