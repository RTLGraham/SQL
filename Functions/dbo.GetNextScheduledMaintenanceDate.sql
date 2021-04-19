SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetNextScheduledMaintenanceDate] 
(
	@DistanceInterval INT,
	@TimeInterval INT,
	@TimeIntervalWeeks INT,
	@FuelInterval INT,
	@EngineInterval INT,
	@CurrentOdo INT,
	@CurrentFuel INT,
	@CurrentEngine INT,
	@LastDate DATETIME,
	@LastOdo INT,
	@LastFuel INT,
	@LastEngine INT
)
RETURNS DATETIME
AS
BEGIN

--	DECLARE @DistanceInterval INT,
--			@TimeInterval INT,
--			@TimeIntervalWeeks INT,
--			@FuelInterval INT,
--			@EngineInterval INT,
--			@CurrentOdo INT,
--			@CurrentFuel INT,
--			@CurrentEngine INT,
--			@LastDate DATETIME,
--			@LastOdo INT,
--			@LastFuel INT,
--			@LastEngine INT
--
--	SET @DistanceInterval = 10000
--	SET	@TimeInterval = NULL
--	SET @TimeIntervalWeeks = 2
--	SET	@FuelInterval = NULL
--	SET	@EngineInterval = NULL
--	SET	@CurrentOdo = 53728
--	SET	@CurrentFuel = 1748
--	SET	@CurrentEngine = 257
--	SET @LastDate = '2014-06-01'
--	SET	@LastOdo = 49639
--	SET @LastFuel = 1639
--	SET @LastEngine = 210

	DECLARE @Result DATETIME,
			@TimeDate DATETIME,
			@DistanceDate DATETIME,
			@FuelDate DATETIME,
			@EngineDate	DATETIME

	SET @Result = '2099-12-31'
	
    IF ISNULL(@TimeInterval, 0) != 0 
    BEGIN 
		SELECT @TimeDate = DATEADD(mm, @TimeInterval, ISNULL(@LastDate, GETDATE()))
		IF ISNULL(@TimeDate, '2099-12-31') < @Result SET @Result = @TimeDate
	END
	
    IF ISNULL(@TimeIntervalWeeks, 0) != 0 
    BEGIN 
		SELECT @TimeDate = DATEADD(ww, @TimeIntervalWeeks, ISNULL(@LastDate, GETDATE()))
		IF ISNULL(@TimeDate, '2099-12-31') < @Result SET @Result = @TimeDate
	END
	
	IF ISNULL(@DistanceInterval, 0) != 0
	BEGIN 
		SELECT @DistanceDate = DATEADD(dd,(@LastOdo + @DistanceInterval - @CurrentOdo)/dbo.ZeroYieldNull(((@CurrentOdo - @LastOdo)/dbo.ZeroYieldNull(DATEDIFF(dd, @LastDate, GETDATE())))), GETDATE())
		--SELECT @DistanceDate = DATEADD(dd,(@LastOdo + @DistanceInterval - @CurrentOdo)/((@CurrentOdo - @LastOdo)/DATEDIFF(dd, @LastDate, GETDATE())), GETDATE())
		IF ISNULL(@DistanceDate, '2099-12-31') < @Result SET @Result = @DistanceDate
	END

	IF ISNULL(@FuelInterval, 0) != 0
	BEGIN 
		SELECT @FuelDate = DATEADD(dd,(@LastFuel + @FuelInterval - @CurrentFuel)/dbo.ZeroYieldNull(((@CurrentFuel - @LastFuel)/dbo.ZeroYieldNull(DATEDIFF(dd, @LastDate, GETDATE())))), GETDATE())
		--SELECT @FuelDate = DATEADD(dd,(@LastFuel + @FuelInterval - @CurrentFuel)/((@CurrentFuel - @LastFuel)/DATEDIFF(dd, @LastDate, GETDATE())), GETDATE())
		IF ISNULL(@FuelDate, '2099-12-31') < @Result SET @Result = @FuelDate
	END

	IF ISNULL(@EngineInterval, 0) != 0
	BEGIN 
		SELECT @EngineDate = DATEADD(dd,(@LastEngine + @EngineInterval - @CurrentEngine)/dbo.ZeroYieldNull(((@CurrentEngine - @LastEngine)/dbo.ZeroYieldNull(DATEDIFF(dd, @LastDate, GETDATE())))), GETDATE())
		--SELECT @EngineDate = DATEADD(dd,(@LastEngine + @EngineInterval - @CurrentEngine)/((@CurrentEngine - @LastEngine)/DATEDIFF(dd, @LastDate, GETDATE())), GETDATE())
		IF ISNULL(@EngineDate, '2099-12-31') < @Result SET @Result = @EngineDate
	END

--	SELECT @Result	
	RETURN @result
END



GO
