SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO






CREATE PROC [dbo].[proc_KB_CreateOrUpdateQuestion]
	@categoryId INT,
	@questionText NVARCHAR(1024),
	@optionA NVARCHAR(1024) = NULL,
	@isACorrect BIT = NULL,
	@optionB NVARCHAR(1024) = NULL,
	@isBCorrect BIT = NULL,
	@optionC NVARCHAR(1024) = NULL,
	@isCCorrect BIT = NULL,
	@optionD NVARCHAR(1024) = NULL,
	@isDCorrect BIT = NULL,
	@uid UNIQUEIDENTIFIER,
	@archived BIT,
	@questionId INT = NULL
AS
BEGIN

	-- Create or edit the question
	IF @questionId IS NULL
	BEGIN
		INSERT INTO dbo.KB_Question
		        (CategoryId,
		         QuestionText,
		         OptionA,
		         IsACorrect,
		         OptionB,
		         IsBCorrect,
		         OptionC,
		         IsCCorrect,
		         OptionD,
		         IsDCorrect,
		         Archived,
		         LastOperation
		        )
		VALUES  (@categoryId, @questionText, @optionA, @isACorrect, @optionB, @isBCorrect, @optionC, @isCCorrect, @optionD, @isDCorrect, @archived, GETDATE())

		SELECT CAST(SCOPE_IDENTITY() AS INT)  AS QuestionId	
	END ELSE
	BEGIN
		UPDATE dbo.KB_Question
		SET CategoryId = @categoryId,
			QuestionText = @questionText,
			OptionA = @optionA,
			IsACorrect = @isACorrect,
			OptionB = @optionB,
			IsBCorrect = @isBCorrect,
			OptionC = @optionC,
			IsCCorrect = @isCCorrect,
			OptionD = @optionD,
			IsDCorrect = @isDCorrect,
			Archived = @archived,
			LastOperation = GETDATE()
		WHERE QuestionId = @questionId
		SELECT @questionId
	END

END	

GO
