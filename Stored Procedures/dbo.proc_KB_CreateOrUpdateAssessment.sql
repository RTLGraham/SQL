SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



CREATE PROC [dbo].[proc_KB_CreateOrUpdateAssessment]
	@fileId INT,
	@AssessmentName VARCHAR(MAX),
	@description VARCHAR(MAX),
	@passScore INT,
	@uid UNIQUEIDENTIFIER,
	@archived BIT,
	@AssessmentId INT = NULL
AS
BEGIN
	IF @AssessmentId IS NULL
	BEGIN
		INSERT INTO dbo.KB_Assessment
				(FileId,
				 Name,
				 Description,
				 CustomerId,
				 PassScore,
				 Archived,
				 LastOperation
				)
		SELECT @fileId, @AssessmentName, @description, u.CustomerID, @passScore, @archived, GETDATE()
		FROM dbo.[User] u
		WHERE u.UserID = @uid
		
		SELECT CAST(SCOPE_IDENTITY() AS INT)  AS AssessmentId	
	END ELSE
	BEGIN
		UPDATE dbo.KB_Assessment
		SET FileId = @fileId,
			Name = @AssessmentName,
			Description = @description,
			CustomerId = u.CustomerId,
			PassScore = @passScore,
			Archived = @archived,
			LastOperation = GETDATE()
		FROM dbo.KB_Assessment a
		CROSS JOIN dbo.[User] u
		WHERE a.AssessmentId = @AssessmentId
		  AND u.UserID = @uid

		SELECT @AssessmentId
	END

END	

GO
