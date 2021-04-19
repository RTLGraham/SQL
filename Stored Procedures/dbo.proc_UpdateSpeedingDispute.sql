SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[proc_UpdateSpeedingDispute] (@eventid BIGINT, @disputestate INT, @disputetypeid INT=NULL)
AS
BEGIN

	UPDATE dbo.EventSpeeding
	SET ChallengeInd = @disputestate, 
		SpeedingDisputeTypeId = CASE WHEN @disputetypeid IS NULL THEN SpeedingDisputeTypeId ELSE @disputetypeid END	
	WHERE EventId = @eventid

	IF @disputestate = 2 -- Challenge has been accepted so reduce Overspeed Distance value accordingly
	BEGIN
		EXEC dbo.proc_RecalcReportingOverspeed @eventid = @eventid
	END	

END	


GO
