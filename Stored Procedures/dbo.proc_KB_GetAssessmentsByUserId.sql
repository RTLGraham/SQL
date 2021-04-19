SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[proc_KB_GetAssessmentsByUserId] (@uid UNIQUEIDENTIFIER)
AS
BEGIN

	--DECLARE @uid UNIQUEIDENTIFIER
	--SET @uid = N'C9F5C0CD-FD03-4512-A78A-A10551F91B4B'
	--SET @uid = N'd5bd4f3e-4df3-4f6b-8a7d-91709ce04b7d'

	DECLARE @cid UNIQUEIDENTIFIER 

	SELECT @cid = CustomerID
	FROM dbo.[User] 
	WHERE UserID = @uid

	SELECT
	   kba.AssessmentId
      ,kba.FileId
      ,kba.Name
      ,kba.Description
      ,kba.PassScore
      ,kba.Archived
	FROM dbo.KB_Assessment kba
	INNER JOIN dbo.KB_File kbf ON kbf.FileId = kba.FileId AND kbf.CustomerId = @cid

END	

GO
