SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[proc_PopulateReportingTemperature] 
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
		AvgAnalogData0 SMALLINT,
		AvgAnalogData1 SMALLINT,
		AvgAnalogData2 SMALLINT,
		AvgAnalogData3 SMALLINT,
		AvgAnalogData4 SMALLINT,
		AvgAnalogData5 SMALLINT,
		Date DATETIME,
		Rows INT
		)

	INSERT INTO @TempTable
			( VehicleIntId ,
			  DriverIntId ,
			  AvgAnalogData0 ,
			  AvgAnalogData1 ,
			  AvgAnalogData2 ,
			  AvgAnalogData3 ,
			  AvgAnalogData4 ,
			  AvgAnalogData5 ,
			  Date ,
			  Rows
			)
	SELECT	VehicleIntId, 
			DriverIntId,
			AVG(AnalogData0),
			AVG(AnalogData1),
			AVG(AnalogData2),
			AVG(AnalogData3),
			AVG(AnalogData4),
			AVG(AnalogData5),
			CAST(YEAR(EventDateTime) AS varchar(4)) + '-' + CAST(dbo.LeadingZero(MONTH(EventDateTime),2) AS varchar(2)) + '-' + CAST(dbo.LeadingZero(DAY(EventDateTime),2) AS varchar(2)) + ' 00:00:00.000',
			COUNT(*)
	FROM dbo.Event WITH (NOLOCK)
	WHERE EventDateTime BETWEEN @sdate AND @edate
	GROUP BY VehicleIntId, DriverIntId, CAST(YEAR(EventDateTime) AS varchar(4)) + '-' + CAST(dbo.LeadingZero(MONTH(EventDateTime),2) AS varchar(2)) + '-' + CAST(dbo.LeadingZero(DAY(EventDateTime),2) AS varchar(2)) + ' 00:00:00.000'

	-- Update any rows that already exist in ReportingTemperature
	UPDATE dbo.ReportingTemperature
	SET AvgAnalogData0 = tt.AvgAnalogData0,
		AvgAnalogData1 = tt.AvgAnalogData1,
		AvgAnalogData2 = tt.AvgAnalogData2,
		AvgAnalogData3 = tt.AvgAnalogData3,
		AvgAnalogData4 = tt.AvgAnalogData4,
		AvgAnalogData5 = tt.AvgAnalogData5,
		Rows = tt.Rows
	FROM dbo.ReportingTemperature rt
	INNER JOIN @TempTable tt ON rt.VehicleIntId = tt.VehicleIntId AND rt.DriverIntId = tt.DriverIntId AND rt.Date = tt.Date

	-- Add any new rows that don't already exist in Reporting Temperature
	INSERT INTO dbo.ReportingTemperature
			( VehicleIntId ,
			  DriverIntId ,
			  AvgAnalogData0 ,
			  AvgAnalogData1 ,
			  AvgAnalogData2 ,
			  AvgAnalogData3 ,
			  AvgAnalogData4 ,
			  AvgAnalogData5 ,
			  Date ,
			  Rows
			)
	SELECT *
	FROM @TempTable tt
	WHERE NOT EXISTS (SELECT 1
					  FROM dbo.ReportingTemperature rt
					  WHERE tt.VehicleIntId = rt.VehicleIntId
						AND tt.DriverIntId = rt.DriverIntId
						AND tt.Date = rt.Date)

END


GO
