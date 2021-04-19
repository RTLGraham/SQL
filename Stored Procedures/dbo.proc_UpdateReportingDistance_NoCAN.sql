SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[proc_UpdateReportingDistance_NoCAN] 
AS

-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

--check we're not already running
SELECT MyVar = 5 INTO ##UpdateReportingRunningTableNG

IF @@ERROR <> 0
BEGIN
	-- do nothing!
	SELECT 0
END ELSE
BEGIN

	DECLARE @DrivingDistance FLOAT,
			@MinDistance FLOAT,
			@MaxDistance FLOAT,
			@VehicleIntId INT,
			@DriverIntId INT,
			@Date SMALLDATETIME

	DECLARE @tempResults table(
			VehicleIntId INT NOT NULL,
			DriverIntId INT NOT NULL,
			Date SMALLDATETIME NOT NULL,
			DrivingDistance FLOAT NOT NULL
			)

	INSERT INTO @tempResults (VehicleIntId,	DriverIntId, Date, DrivingDistance)
	SELECT r.VehicleIntId, r.DriverIntId, r.Date, r.DrivingDistance
	FROM dbo.Reporting r
		INNER JOIN dbo.Vehicle v ON r.VehicleIntId = v.VehicleIntId
	WHERE r.Date > DATEADD(dd, -2, GETUTCDATE())
	  AND r.DrivingDistance = 0
	  AND v.IsCAN = 0					/* only for non-CAN vehicles */
	  AND v.VehicleTypeID != 4000000	/*		exclude trailers	 */
	  	  
	DECLARE tempCursor CURSOR FAST_FORWARD READ_ONLY
	FOR SELECT VehicleIntId, DriverIntId, Date FROM @tempResults

	OPEN tempCursor
	FETCH NEXT FROM tempCursor INTO @VehicleIntId, @DriverIntId, @Date
					
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SELECT TOP 1 @MinDistance = ISNULL(OdoGPS,0)
		FROM dbo.Event
		WHERE VehicleIntId = @VehicleIntId AND DriverIntId = @DriverIntId AND EventDateTime <= @Date
		ORDER BY EventDateTime DESC
		  
		SELECT TOP 1 @MaxDistance = ISNULL(OdoGPS,0)
		FROM dbo.Event
		WHERE VehicleIntId = @VehicleIntId AND DriverIntId = @DriverIntId AND EventDateTime <= DATEADD(dd, 1, @Date)
		ORDER BY EventDateTime DESC
		
		IF (@MaxDistance - @MinDistance) > 1000 -- some distance in metres to allow drift
		BEGIN
			UPDATE @tempResults
			SET DrivingDistance = (@MaxDistance - @MinDistance) / 1000
			WHERE VehicleIntId = @VehicleIntId AND DriverIntId = @DriverIntId AND Date = @Date	
		END
		
		FETCH NEXT FROM tempCursor INTO @VehicleIntId, @DriverIntId, @Date
	END

	CLOSE tempCursor
	DEALLOCATE tempCursor
	
	UPDATE dbo.Reporting
	SET DrivingDistance = t.DrivingDistance
	FROM dbo.Reporting r
	INNER JOIN @tempResults t ON r.Date = t.Date AND r.VehicleIntId = t.VehicleIntId AND r.DriverIntId = t.DriverIntId
	WHERE t.DrivingDistance > 0

END -- End of already running test

DROP TABLE ##UpdateReportingRunningTableNG




GO
