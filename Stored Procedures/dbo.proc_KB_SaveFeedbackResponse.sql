SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[proc_KB_SaveFeedbackResponse] (@feedbackid INT, @qid INT, @response TINYINT)
AS
BEGIN

	INSERT INTO dbo.KB_AssessmentFeedbackDetail
	        (AssessmentFeedbackId,
	         FeedbackQuestionId,
	         Response,
	         Archived,
	         LastOperation
	        )
	VALUES  (@feedbackid, -- AssessmentFeedbackId - int
	         @qid, -- FeedbackQuestionId - int
	         @response, -- Response - tinyint
	         0, -- Archived - bit
	         GETDATE()  -- LastOperation - smalldatetime
	        )

END	


GO
