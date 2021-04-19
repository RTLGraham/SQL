SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_KB_GetAssessmentDetailsById] (@asid INT)
AS
BEGIN

	--DECLARE @asid INT
	--SET @asid = 1

	SELECT c.CategoryId,
       c.Name AS CategoryName,
       c.Description,
       c.AssessmentId,
       c.NumQuestions AS QuestionsForShow,
       q.QuestionId,
       q.QuestionText,
       q.OptionA,
       q.IsACorrect,
       q.OptionB,
       q.IsBCorrect,
       q.OptionC,
       q.IsCCorrect,
       q.OptionD,
       q.IsDCorrect,
       q.Archived
	FROM dbo.KB_Category c
	INNER JOIN dbo.KB_Question q ON q.CategoryId = c.CategoryId
	WHERE c.AssessmentId = @asid
	  AND c.Archived = 0
	  AND q.Archived = 0
	
END	

GO
