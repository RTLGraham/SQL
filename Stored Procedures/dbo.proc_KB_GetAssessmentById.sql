SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO





CREATE PROCEDURE [dbo].[proc_KB_GetAssessmentById] (@aid INT)
AS
BEGIN

	--DECLARE @aid INT
	--SET @aid = 1;

	DECLARE @rowid INT
	SET @rowid = 1
	DECLARE @results TABLE
    (
		QId INT IDENTITY (1,1),
		AssessmentId INT,
		AssessmentCategoryId INT,
		QuestionId INT	
	)

	DECLARE @acid INT,
			@minqid INT,
			@maxqid INT,
			@randqid INT,
			@duplicate BIT	

	-- A CTE is used to identify the number of question required for each category
	-- A cursor is then used on the results of the CTE so that questions can be selected for each category at random, ensuring that no duplicate questions are returned (not easily possible without a cursor) 

	DECLARE @QCur CURSOR; 
	SET @QCur = CURSOR FOR
	WITH Question_CTE (RowId, AssessmentId, CategoryId, NumQuestions, MinQId, MaxQId) AS	
	(
	SELECT @rowid, a.AssessmentId, c.CategoryId, c.NumQuestions, MIN(QuestionId) AS MinQId, MAX(q.QuestionId) AS MaxQId
	FROM dbo.KB_Assessment a
	INNER JOIN dbo.KB_Category c ON c.AssessmentId = a.AssessmentId
	INNER JOIN dbo.KB_Question q ON q.CategoryId = c.CategoryId
	WHERE a.AssessmentId = @aid
	  AND q.Archived = 0
	GROUP BY a.AssessmentId, c.CategoryId, c.NumQuestions

	UNION ALL
    
	SELECT cte.RowId + 1, a.AssessmentId, c.CategoryId, c.NumQuestions, cte.MinQId, cte.MaxQId
	FROM Question_CTE cte
	INNER JOIN dbo.KB_Assessment a ON a.AssessmentId = cte.AssessmentId
	INNER JOIN dbo.KB_Category c ON c.AssessmentId = a.AssessmentId
	WHERE a.AssessmentId = @aid
	  AND cte.CategoryId = c.CategoryId
	  AND cte.RowId < c.NumQuestions)
    
	SELECT cte.CategoryId, cte.MinQId, cte.MaxQId
	FROM Question_CTE cte
	ORDER BY cte.CategoryId

	OPEN @QCur
	FETCH NEXT FROM @QCur INTO @acid, @minqid, @maxqid

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SET @duplicate = 1
		WHILE @duplicate > 0
		BEGIN
			SELECT @randqid = @minqid + FLOOR((@maxqid - @minqid + 1) * RAND(CONVERT(VARBINARY, NEWID()))) -- generates a random number between the min and max question ids provided
			SELECT @duplicate = COUNT(*)
			FROM @results
			WHERE QuestionId = @randqid
		END	

		INSERT INTO @results (AssessmentId, AssessmentCategoryId, QuestionId)
		SELECT @aid, @acid, @randqid
        
    
		FETCH NEXT FROM @QCur INTO @acid, @minqid, @maxqid
	END	

	SELECT a.AssessmentId, a.Name, a.Description, a.PassScore, c.CategoryId, c.Name AS CategoryName, c.Description AS CategoryDescription, r.QId AS QuestionNum, q.QuestionId, q.QuestionText, q.OptionA, q.IsACorrect, q.OptionB, q.IsBCorrect, q.OptionC, q.IsCCorrect, q.OptionD, q.IsDCorrect
	FROM @results r
	INNER JOIN dbo.KB_Question q ON q.QuestionId = r.QuestionId
	INNER JOIN dbo.KB_Category c ON c.CategoryId = q.CategoryId
	INNER JOIN dbo.KB_Assessment a ON a.AssessmentId = c.AssessmentId
	ORDER BY r.QId

END	

GO
