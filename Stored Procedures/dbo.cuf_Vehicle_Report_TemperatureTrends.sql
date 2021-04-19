SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_Report_TemperatureTrends]
(
	@vids varchar(max) = NULL,
	@gids varchar(max) = NULL,
	@startDate datetime,
	@endDate datetime,
	@routeId int = NULL,
	@vehicleTypeId int = NULL,
	@userId uniqueidentifier,
	@configId UNIQUEIDENTIFIER,
	@groupBy INT,
	@rptlevel INT = NULL
)
AS

--DECLARE	@vids varchar(max),
--	@gids varchar(max),
--	@startDate datetime,
--	@endDate datetime,
--	@routeId int,
--	@vehicleTypeId int,
--	@userId uniqueidentifier,
--	@configId UNIQUEIDENTIFIER
--	
--SET @vids = NULL --N'16DF929B-A773-46D2-900E-2CA8DCF23893,87A3B70E-9B8D-42CB-BB13-2E1C9427331C,93431E81-EE44-4EEE-A959-387B6E4F9CE3'
--SET @gids = N'EA6FF8F6-F6EA-4632-9607-7B0A8A8A8DDB,139C25F1-80AB-409E-B040-7CA42D79C9F6'
--SET @vehicletypeid = NULL
--SET @routeid = NULL
--SET	@startdate = '2011-10-16 10:00'
--SET	@enddate = '2012-03-10 17:00'
--SET	@userid = N'C21039E7-58BE-4748-9A92-9AAB74AED58E'
--SET	@configid = N'77C80BDB-5827-4C5E-BBF4-06F36ACB47D6'

	DECLARE @Results TABLE (
	
		-- Vehicle, Driver and Group Identification columns
		PeriodNum INT,
		WeekStartDate DATETIME,
		WeekEndDate DATETIME,
		PeriodType VARCHAR(MAX),
		GroupId UNIQUEIDENTIFIER,	
		GroupName VARCHAR(MAX),
		VehicleId UNIQUEIDENTIFIER,	
		Registration VARCHAR(MAX),
        OutsideTime INT,
		WeakestPercentage FLOAT,
		AveragePercentage FLOAT,
		TotalOverTempDuration INT,
		WeakestOverTempDuration INT,
        Confirmed INT,
        NonConfirmed INT,
        AvgProductTempInside FLOAT,
        AvgProductTempOutside FLOAT,
        AvgExternalTempOutside FLOAT,
        DefrostCount INT
	)
                    
	IF (@vids IS NULL AND @gids IS NULL) OR @rptlevel = 1 -- full fleet report
	BEGIN	
	INSERT INTO @Results
		EXEC dbo.proc_Report_TemperatureTrend_Fleet
					@vids = @vids,
					@gids = @gids,
                    @sdate = @startDate,
                    @edate = @endDate,
                    @routeid = @routeid,
                    @vehicletypeid = @vehicleTypeId,
                    @uid = @userId,
                    @rprtcfgid = @configId,
                    @drilldown = 1,
                    @calendar = 0,
                    @groupBy = @groupBy;
		SELECT *
		FROM @Results
		WHERE VehicleId IS NULL AND GroupId IS NULL AND PeriodNum IS NOT NULL
		ORDER BY PeriodNum
	END
	
	IF (@vids IS NULL AND @gids IS NOT NULL) OR @rptlevel = 2 -- vehicle group report
	BEGIN
	INSERT INTO @Results
		EXEC dbo.proc_Report_TemperatureTrend_VehicleGroup
					@vids = @vids,
                    @gids = @gids,
                    @sdate = @startDate,
                    @edate = @endDate,
                    @routeid = @routeid,
                    @vehicletypeid = @vehicleTypeId,
                    @uid = @userId,
                    @rprtcfgid = @configId,
                    @drilldown = 1,
                    @calendar = 0,
                    @groupBy = @groupBy;
		SELECT *
		FROM @Results
		WHERE VehicleId IS NULL AND GroupId IS NOT NULL AND PeriodNum IS NOT NULL
		ORDER BY GroupName, PeriodNum
	END
	
	IF (@vids IS NOT NULL AND @gids IS NULL) OR @rptlevel = 3 -- report by vehicle
	BEGIN
		INSERT INTO @Results
		EXEC dbo.proc_Report_TemperatureTrend_Vehicle
	  				@vids = @vids,
                    @sdate = @startDate,
                    @edate = @endDate,
                    @routeid = @routeid,
                    @vehicletypeid = @vehicleTypeId,
                    @uid = @userId,
                    @rprtcfgid = @configId,
                    @drilldown = 1,
                    @calendar = 0,
                    @groupBy = @groupBy;
		SELECT *
		FROM @Results
		WHERE VehicleId IS NOT NULL AND GroupId IS NULL AND PeriodNum IS NOT NULL
		ORDER BY Registration, PeriodNum
	END
	

GO
