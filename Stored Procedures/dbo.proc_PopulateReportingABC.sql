SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Dmtirijs Jurins> 
-- Create date: <2015-02-21>
-- Description:	<Process IT camera harsh events from EventCopyABC>
-- =============================================
CREATE PROCEDURE [dbo].[proc_PopulateReportingABC] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--check we're not already running
	SELECT MyVar = 5 INTO #PopulateReportingABCfromEventCopyABC

	IF @@ERROR <> 0
	BEGIN
		-- do nothing!
		SELECT 0
	END
	ELSE
	BEGIN
		
		/* ----------------------------------------------------------------------------------	*/
		/* Mark all records to be processed in 'copy' table					            		*/
		UPDATE dbo.EventCopyABC SET Archived = 1 WHERE Archived = 0
		/* ----------------------------------------------------------------------------------	*/
		
		DECLARE @TempTable TABLE 
		(
			[Date] DATETIME,
			VehicleIntId INT,
			DriverIntId INT,
			CreationCodeId INT,
			TotalCount INT
		)
		
		-- Insert rows into the temp table for processing for Vehicles with NO Camera fitted ONLY		
		INSERT INTO @TempTable
		( 
			[Date] ,
			VehicleIntId ,
			DriverIntId ,
			CreationCodeId ,
			TotalCount
		)
		SELECT 
			CAST(FLOOR(CAST(abc.EventDateTime AS FLOAT)) AS DATETIME),
			abc.VehicleIntId,
			abc.DriverIntId,
			abc.CreationCodeId,
			COUNT(*)
		FROM dbo.EventCopyABC abc
		INNER JOIN dbo.Vehicle v ON abc.VehicleIntId = v.VehicleIntId
		LEFT JOIN dbo.VehicleCamera vc ON v.VehicleId = vc.VehicleId AND vc.Archived = 0 AND vc.EndDate IS NULL
		WHERE abc.Archived = 1
		  AND vc.VehicleId IS NULL
		GROUP BY 
			CAST(FLOOR(CAST(abc.EventDateTime AS FLOAT)) AS DATETIME),
			abc.VehicleIntId,
			abc.DriverIntId,
			abc.CreationCodeId

		DECLARE @ReportingABC TABLE 
		(
			[Date] DATETIME,
			VehicleIntId INT,
			DriverIntId INT,
		    
			Acceleration INT,
			Braking INT,
			Cornering INT,
		    
			AccelerationLow INT,
			BrakingLow INT,
			CorneringLow INT,
		    
			AccelerationHigh INT,
			BrakingHigh INT,
			CorneringHigh INT	    
		)

		INSERT INTO @ReportingABC
		( 
			[Date] ,
			VehicleIntId ,
			DriverIntId
		)
		SELECT DISTINCT [Date], VehicleIntId, DriverIntId
		FROM @TempTable 
		
		
		UPDATE @ReportingABC
		SET 
			Acceleration = ISNULL(a.TotalCount,0), 
			Braking = ISNULL(b.TotalCount,0), 
			Cornering = ISNULL(c.TotalCount,0),
			
			AccelerationLow = ISNULL(aLow.TotalCount,0), 
			BrakingLow = ISNULL(bLow.TotalCount,0), 
			CorneringLow = ISNULL(cLow.TotalCount,0),
			
			AccelerationHigh = ISNULL(aHigh.TotalCount,0), 
			BrakingHigh = ISNULL(bHigh.TotalCount,0), 
			CorneringHigh = ISNULL(cHigh.TotalCount,0)
		FROM @ReportingABC abc
			LEFT JOIN @TempTable a ON abc.VehicleIntId = a.VehicleIntId AND abc.DriverIntId = a.DriverIntId AND abc.Date = a.Date AND a.CreationCodeId IN (37, 458)
			LEFT JOIN @TempTable b ON abc.VehicleIntId = b.VehicleIntId AND abc.DriverIntId = b.DriverIntId AND abc.Date = b.Date AND b.CreationCodeId = 36
			LEFT JOIN @TempTable c ON abc.VehicleIntId = c.VehicleIntId AND abc.DriverIntId = c.DriverIntId AND abc.Date = c.Date AND c.CreationCodeId = 38
			LEFT JOIN @TempTable aLow ON abc.VehicleIntId = aLow.VehicleIntId AND abc.DriverIntId = aLow.DriverIntId AND abc.Date = aLow.Date AND aLow.CreationCodeId IN (337, 457)
			LEFT JOIN @TempTable bLow ON abc.VehicleIntId = bLow.VehicleIntId AND abc.DriverIntId = bLow.DriverIntId AND abc.Date = bLow.Date AND bLow.CreationCodeId = 336
			LEFT JOIN @TempTable cLow ON abc.VehicleIntId = cLow.VehicleIntId AND abc.DriverIntId = cLow.DriverIntId AND abc.Date = cLow.Date AND cLow.CreationCodeId = 338
			LEFT JOIN @TempTable aHigh ON abc.VehicleIntId = aHigh.VehicleIntId AND abc.DriverIntId = aHigh.DriverIntId AND abc.Date = aHigh.Date AND aHigh.CreationCodeId = 437
			LEFT JOIN @TempTable bHigh ON abc.VehicleIntId = bHigh.VehicleIntId AND abc.DriverIntId = bHigh.DriverIntId AND abc.Date = bHigh.Date AND bHigh.CreationCodeId = 436
			LEFT JOIN @TempTable cHigh ON abc.VehicleIntId = cHigh.VehicleIntId AND abc.DriverIntId = cHigh.DriverIntId AND abc.Date = cHigh.Date AND cHigh.CreationCodeId = 438

		-- Update any rows that already exist in ReportingABC
		UPDATE dbo.ReportingABC
		SET 
			Acceleration = ISNULL(r.Acceleration, 0) + abc.Acceleration,
			Braking = ISNULL(r.Braking, 0) + abc.Braking,
			Cornering = ISNULL(r.Cornering, 0) + abc.Cornering,
			
			AccelerationLow = ISNULL(r.AccelerationLow, 0) + abc.AccelerationLow,
			BrakingLow = ISNULL(r.BrakingLow, 0) + abc.BrakingLow,
			CorneringLow = ISNULL(r.CorneringLow, 0) + abc.CorneringLow,
			
			AccelerationHigh = ISNULL(r.AccelerationHigh, 0) + abc.AccelerationHigh,
			BrakingHigh = ISNULL(r.BrakingHigh, 0) + abc.BrakingHigh,
			CorneringHigh = ISNULL(r.CorneringHigh, 0) + abc.CorneringHigh
		FROM dbo.ReportingABC r
			INNER JOIN @ReportingABC abc ON r.VehicleIntId = abc.VehicleIntId 
										AND r.DriverIntId = abc.DriverIntId 
										AND r.Date = abc.Date

		-- Add any new rows that don't already exist in ReportingABC
		INSERT INTO dbo.ReportingABC
				( VehicleIntId ,
				  DriverIntId ,
				  
				  Acceleration ,
				  Braking ,
				  Cornering ,
				  
				  AccelerationLow ,
				  BrakingLow ,
				  CorneringLow ,
				  
				  AccelerationHigh ,
				  BrakingHigh ,
				  CorneringHigh ,
				  
				  Date 
				)
		SELECT	  VehicleIntId ,
				  DriverIntId ,
				  
				  Acceleration ,
				  Braking ,
				  Cornering ,
				  
				  AccelerationLow ,
				  BrakingLow ,
				  CorneringLow ,
				  
				  AccelerationHigh ,
				  BrakingHigh ,
				  CorneringHigh ,
				  
				  Date 
		FROM @ReportingABC abc
		WHERE NOT EXISTS (SELECT 1
						  FROM dbo.ReportingABC r
						  WHERE abc.VehicleIntId = r.VehicleIntId
							AND abc.DriverIntId = r.DriverIntId
							AND abc.Date = r.Date)
		
		/* --------------------------------------------------------------------- */
		/* Delete any records that were in the table when we started			*/
		DELETE FROM dbo.EventCopyABC WHERE Archived = 1
		/* --------------------------------------------------------------------- */
		
	END -- End of already running test

	DROP TABLE #PopulateReportingABCfromEventCopyABC

END

GO
