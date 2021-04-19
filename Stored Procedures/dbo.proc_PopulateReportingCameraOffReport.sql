SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_PopulateReportingCameraOffReport]
(
	@cIntid INT,
	@date DATETIME = NULL
)
AS
	--DECLARE	@date DATETIME,
	--		@cIntid INT
			
	--SELECT  @date = NULL,
	--		@cIntid = 58

	IF @date IS NULL
	BEGIN
		SET @date = DATEADD(DAY,-1, CAST(FLOOR(CAST(GETDATE() AS float)) AS DATETIME))
	END	           

	
	DECLARE @edate DATETIME,
			@threshold INT
	
	SET @threshold = 10
	SET @edate = DATEADD(SECOND, -1, DATEADD(DAY, 1, @date))
	
	INSERT INTO dbo.ReportingCameraOff
	        ( CustomerIntId ,
	          VehicleIntId ,
	          DriverIntId ,
	          Date ,
	          OffEvents ,
	          OnEvents ,
	          ThresholdKMH
	        )
	SELECT 
		e.CustomerIntId,
		e.VehicleIntId,
		e.DriverIntId,
		@date AS [Date],
		SUM(CASE WHEN e.DigitalIO & 8  = 0 THEN 1 ELSE 0 END) AS OffEvents,
		SUM(CASE WHEN e.DigitalIO & 8 != 0 THEN 1 ELSE 0 END) AS OonEvents,
		@threshold AS ThresholdKMH
	FROM dbo.Event e WITH (NOLOCK)
		INNER JOIN dbo.Vehicle v ON v.VehicleIntId = e.VehicleIntId
		INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
		INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
	WHERE c.CustomerIntId = @cIntid
		AND e.EventDateTime BETWEEN @date AND @edate
		AND e.Speed > @threshold
	GROUP BY e.CustomerIntId, e.VehicleIntId, e.DriverIntId

GO
