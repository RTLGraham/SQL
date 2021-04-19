SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO





CREATE PROC [dbo].[proc_KB_CreateOrUpdateCategory]
	@CategoryName VARCHAR(MAX),
	@description VARCHAR(MAX),
	@assessmentId INT,
	@numQuestions INT,
	@uid UNIQUEIDENTIFIER,
	@archived BIT,
	@CategoryId INT = NULL
AS
BEGIN
	IF @CategoryId IS NULL
	BEGIN
		INSERT INTO dbo.KB_Category
				(Name,
				 Description,
				 AssessmentId,
				 NumQuestions,
				 Archived,
				 LastOperation
				)
		VALUES (@CategoryName, @description, @assessmentId, @numQuestions, @archived, GETDATE())

		SELECT CAST(SCOPE_IDENTITY() AS INT)  AS CategoryId	
	END ELSE
	BEGIN
		UPDATE dbo.KB_Category
		SET Name = @CategoryName,
			Description = @description,
			AssessmentId = @assessmentId,
			NumQuestions = @numQuestions,
			Archived = @archived,
			LastOperation = GETDATE()
		FROM dbo.KB_Category
		WHERE CategoryId = @CategoryId
		  
		SELECT @CategoryId
	END

END	

GO
