SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[proc_KB_SaveFeedback] (@asid INT, @did UNIQUEIDENTIFIER, @comment NVARCHAR(1024) = NULL)
AS
BEGIN

	DECLARE @driverIntId INT

	SELECT @driverIntId = DriverIntId
	FROM dbo.Driver
	WHERE DriverId = @did
	

	INSERT INTO dbo.KB_AssessmentFeedback
	        (AssessmentId,
	         DriverIntId,
	         FeedbackDateTime,
	         AssessmentFeedbackText,
	         Archived,
	         LastOperation
	        )
	VALUES  (@asid, -- AssessmentId - int
	         @driverIntId, -- DriverIntId - int
	         GETUTCDATE(), -- FeedbackDateTime - datetime
	         @comment, -- AssessmentFeedbackText - nvarchar(1024)
	         0, -- Archived - bit
	         GETDATE()  -- LastOperation - smalldatetime
	        )

	SELECT SCOPE_IDENTITY() AS FeedbackId

END	


GO
