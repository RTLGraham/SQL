SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_TripAnalysisSchedule]
AS

DECLARE @InProgress INT,
		@RequestId INT,
		@BaseGeoId UNIQUEIDENTIFIER,
		@sdate DATETIME,
		@edate DATETIME,
		@uid UNIQUEIDENTIFIER,
		@cache INT

-- First check to see if any Trip Analysis Requests are already in progress (status = 0)
SET @InProgress = NULL
SELECT @InProgress = COUNT(*)
FROM dbo.TripAnalysisRequest
WHERE Status IN (2,3,4) -- Caching, Analysing or Exporting

IF ISNULL(@InProgress, 0) = 0 -- OK to proceed and run the next available analysis
BEGIN
	SET @RequestId = NULL
	SELECT TOP 1 @RequestId = TripAnalysisRequestID, @BaseGeoId = BaseGeofenceID, @sdate = StartDate, @edate = EndDate, @uid = UserID
	FROM dbo.TripAnalysisRequest
	WHERE Status = 1
	  AND Archived = 0
	ORDER BY RequestDate

	IF @RequestId IS NOT NULL
	BEGIN
		
		-- Set execution start date on request
		UPDATE dbo.TripAnalysisRequest
		SET ExecutionStartDate = GETUTCDATE()
		WHERE TripAnalysisRequestID = @RequestId
		
		-- First determine whether caching needs to be performed
		SET @cache = NULL
		SELECT @cache = COUNT(*)
		FROM dbo.TripAnalysisRequest
		WHERE BaseGeofenceID = @BaseGeoId
		  AND StartDate <= @sdate
		  AND EndDate >= @edate
		  AND Status = 5 -- Completed
		  AND TripAnalysisRequestID != @RequestId
		
		IF ISNULL(@cache, 0) = 0 -- No current cache exists
		BEGIN
			-- Mark request as 'Caching'
			UPDATE dbo.TripAnalysisRequest
			SET Status = 2
			WHERE TripAnalysisRequestID = @RequestId
			EXEC dbo.proc_TripAnalysisCache @RequestId
		END
		
		-- Execute the analysis
		-- Mark request as 'Analysing'
		UPDATE dbo.TripAnalysisRequest
		SET Status = 3
		WHERE TripAnalysisRequestID = @RequestId
		EXEC dbo.proc_TripAnalysisAnalyse @RequestId
		
		-- Export the results to excel
		DECLARE @rc INT
		-- Mark request as 'Exporting'
		UPDATE dbo.TripAnalysisRequest
		SET Status = 4
		WHERE TripAnalysisRequestID = @RequestId
		EXEC @rc = dbo.clr_ExportTripAnalysis @uid, @RequestId
		PRINT @rc
		
		-- Update the Trip Request 
		IF @rc = 0
		BEGIN
			UPDATE dbo.TripAnalysisRequest
			SET Status = 5,
			CompletionDate = GETDATE(),
			LastOperation = GETDATE()
			WHERE TripAnalysisRequestID = @RequestId
		END ELSE
		BEGIN
			UPDATE dbo.TripAnalysisRequest
			SET Status = 6, -- change this to a failed status
			LastOperation = GETDATE()
			WHERE TripAnalysisRequestID = @RequestId
		END
	END
END


GO
