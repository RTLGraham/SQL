SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[zz_remove_proc_PopulateReportingABCOrig] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Always run for today and the last 2 days to capture any late data
	DECLARE @sdate DATETIME,
			@edate DATETIME
	SET @edate = GETDATE()
	SET @sdate = DATEADD(DAY, -2, @edate)

	DECLARE @TempTable TABLE (
		VehicleIntId INT,
		DriverIntId INT,
		CreationCodeId INT,
		TotalCount INT,
		Date DATETIME
		)

	INSERT INTO @TempTable
			( VehicleIntId ,
			  DriverIntId ,
			  CreationCodeId ,
			  TotalCount ,
			  Date 
			)
	SELECT	VehicleIntId, 
			DriverIntId,
			CreationCodeId,
			COUNT(CreationCodeId),
			CAST(YEAR(EventDateTime) AS varchar(4)) + '-' + CAST(dbo.LeadingZero(MONTH(EventDateTime),2) AS varchar(2)) + '-' + CAST(dbo.LeadingZero(DAY(EventDateTime),2) AS varchar(2)) + ' 00:00:00.000'
	FROM dbo.Event WITH (NOLOCK)
	WHERE EventDateTime BETWEEN @sdate AND @edate
	  AND CreationCodeId IN (36,37,38) 
	  AND Lat != 0 AND Long != 0 
	GROUP BY VehicleIntId, DriverIntId, CreationCodeId, CAST(YEAR(EventDateTime) AS varchar(4)) + '-' + CAST(dbo.LeadingZero(MONTH(EventDateTime),2) AS varchar(2)) + '-' + CAST(dbo.LeadingZero(DAY(EventDateTime),2) AS varchar(2)) + ' 00:00:00.000'

	-- Combine values into single reporting rows per vehicle / driver / date
	DECLARE @ABC TABLE (
		VehicleIntId INT,
	    DriverIntId INT,
	    Acceleration INT,
	    Braking INT,
	    Cornering INT,
	    Date DATETIME)

	INSERT INTO @ABC
	        ( VehicleIntId,
	          DriverIntId,
	          Date
	        )
	SELECT DISTINCT VehicleIntId, DriverIntId, Date
	FROM @TempTable 
	
	UPDATE @ABC
	SET Acceleration = ISNULL(a.TotalCount,0), 
		Braking = ISNULL(b.TotalCount,0), 
		Cornering = ISNULL(c.TotalCount,0)
	FROM @ABC abc
	LEFT JOIN @TempTable a ON abc.VehicleIntId = a.VehicleIntId AND abc.DriverIntId = a.DriverIntId AND abc.Date = a.Date AND a.CreationCodeId = 37
	LEFT JOIN @TempTable b ON abc.VehicleIntId = b.VehicleIntId AND abc.DriverIntId = b.DriverIntId AND abc.Date = b.Date AND b.CreationCodeId = 36
	LEFT JOIN @TempTable c ON abc.VehicleIntId = c.VehicleIntId AND abc.DriverIntId = c.DriverIntId AND abc.Date = c.Date AND c.CreationCodeId = 38
	
	-- Update any rows that already exist in ReportingABC
	UPDATE dbo.ReportingABC
	SET Acceleration = abc.Acceleration,
		Braking = abc.Braking,
		Cornering = abc.Cornering
	FROM dbo.ReportingABC r
	INNER JOIN @ABC abc ON r.VehicleIntId = abc.VehicleIntId AND r.DriverIntId = abc.DriverIntId AND r.Date = abc.Date

	-- Add any new rows that don't already exist in ReportingABC
	INSERT INTO dbo.ReportingABC
			( VehicleIntId ,
			  DriverIntId ,
			  Acceleration ,
			  Braking ,
			  Cornering ,
			  Date 
			)
	SELECT *
	FROM @ABC abc
	WHERE NOT EXISTS (SELECT 1
					  FROM dbo.ReportingABC r
					  WHERE abc.VehicleIntId = r.VehicleIntId
						AND abc.DriverIntId = r.DriverIntId
						AND abc.Date = r.Date)

END


GO
