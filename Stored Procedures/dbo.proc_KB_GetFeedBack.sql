SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_KB_GetFeedBack] (@asid INT, @culture NVARCHAR(10) = NULL)
AS
BEGIN
	
	--DECLARE @culture NVARCHAR(10),
	--		@asid INT

	--SET @asid = 85

	IF @asid = 85
	BEGIN 
		SET @culture  = 'es-ES'
	END

	DECLARE @Results TABLE
	(
	       FeedbackQuestionId INT,
		   FeedbackQuestionText NVARCHAR(1024),
		   OptionA  NVARCHAR(1024),
           OptionB NVARCHAR(1024),
           OptionC NVARCHAR(1024),
           OptionD NVARCHAR(1024),
		   Position INT
	)


	DECLARE @fmtonlyON BIT

IF (1=0) BEGIN
SET FMTONLY ON
SELECT
		   FeedbackQuestionId,
           FeedbackQuestionText,
           OptionA,
           OptionB,
           OptionC,
           OptionD
	FROM dbo.KB_FeedbackQuestion

 END
 ELSE
 BEGIN

	INSERT INTO @Results
	SELECT QuestionId as FeedbackQuestionId,
           FeedbackQuestionText,
           OptionA,
           OptionB,
           OptionC,
           OptionD,
		   Position
	FROM dbo.KB_FeedbackQuestion
	WHERE Archived = 0 AND ISNULL(Culture,'') = ISNULL(@culture,'')

	IF((SELECT COUNT(*)FROM @Results)=0)
	BEGIN
	INSERT INTO @Results
	SELECT QuestionId as FeedbackQuestionId,
           FeedbackQuestionText,
           OptionA,
           OptionB,
           OptionC,
           OptionD,
		   Position
	FROM dbo.KB_FeedbackQuestion
	WHERE Archived = 0 AND Culture IS NULL

	END
	SELECT
		   FeedbackQuestionId,
           FeedbackQuestionText,
           OptionA,
           OptionB,
           OptionC,
           OptionD
	FROM @Results
	ORDER BY Position

END
END



GO
