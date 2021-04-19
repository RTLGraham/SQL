SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_ProcessSCAMVideoIn]
AS
BEGIN

/****************************************************************************/
/*                                                                          */
/* This process runs periodically and matches actual videos received        */
/* with videos expected (from SCAM_DataIn that had CAM_Video entries        */
/* pre-created). The details are updated to allow the video to be streamed. */
/*                                                                          */
/****************************************************************************/

	-- Mark data to be processed
	UPDATE dbo.SCAM_VideoIn
	SET ProcessInd = 1
	WHERE ProcessInd = 0

	-- Find rows that match the CAM_Video table and update accordingly
	UPDATE dbo.CAM_Video
	SET VideoStatus = s.VideoStatus,
	ApiFileName = s.Acc,
	ApiStartTime = s.Stime,
	ApiEndTime = s.Etime
	FROM dbo.SCAM_VideoIn s
	INNER JOIN dbo.CAM_Video v ON v.ApiEventId = s.Video
	WHERE s.ProcessInd = 1

	-- Delete rows from SCAM_VideoIn that were matched. Unmatched rows remain in the SCAM_VideoIn holding table.
	DELETE FROM dbo.SCAM_VideoIn
	FROM dbo.SCAM_VideoIn s
	INNER JOIN dbo.CAM_Video v ON v.ApiEventId = s.Video
	WHERE s.ProcessInd = 1

END	
GO
