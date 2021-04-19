SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- ====================================================================
-- Author:		Dmitrijs Jurins
-- Create date: 28/08/2017
-- Description:	Returns the previous coaching status. Sometimes we need to know from which status did the video transist.
-- ====================================================================
CREATE FUNCTION [dbo].[GetPreviousCoachingStatus] 
(
	@incidentId BIGINT,
	@currentStatus INT
)
RETURNS INT
AS
BEGIN
	DECLARE @result INT
	
	SELECT TOP 1 @result = CoachingStatusId
	FROM dbo.VideoCoachingHistory
	WHERE IncidentId = @incidentId
		AND CoachingStatusId != @currentStatus 
		AND Archived = 0
	ORDER BY VideoCoachingId DESC 

	--SELECT @result = CoachingStatusId
	--FROM 
	--(
	--	SELECT TOP 2 ROW_NUMBER() OVER (ORDER BY VideoCoachingId DESC) AS RowNumber, CoachingStatusId
	--	FROM dbo.VideoCoachingHistory
	--	WHERE IncidentId = @incidentId
	--		AND CoachingStatusId != @currentStatus 
	--		AND Archived = 0
	--	ORDER BY VideoCoachingId DESC 
	--) t
	--WHERE RowNumber = 2

	RETURN @result
END

GO
