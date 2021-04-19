SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Customer_CheckImportFromTravido]
(
	@new_cname NVARCHAR(100), 
	@new_pid VARCHAR(20), 
	@new_pun VARCHAR(20)
)
AS	
	DECLARE @result BIT,
			@fault NVARCHAR(MAX)
    SELECT	@result = 0, @fault = NULL
	
	IF @result = 0
	BEGIN

		SELECT @result = COUNT(*), @fault = CASE WHEN COUNT(*) > 0 THEN 'Customer already exist' ELSE NULL END
		FROM dbo.Customer
		WHERE Archived = 0 AND Name = @new_cname
	
	END

	IF @result = 0
	BEGIN

		SELECT @result = COUNT(*), @fault = CASE WHEN COUNT(*) > 0 THEN 'Project already exist' ELSE NULL END
		FROM dbo.Project
		WHERE Archived = 0 AND Project = @new_pid

	END

	IF @result = 0
	BEGIN

		SELECT @result = CASE WHEN LEN(@new_pun) >= 20 THEN 1 ELSE 0 END, @fault = CASE WHEN LEN(@new_pun) >= 20 THEN 'User name is too long' ELSE NULL END
		FROM dbo.Customer
		WHERE Archived = 0 AND Name = @new_cname
	
	END

	SELECT @result AS Faults, @fault AS FaultDescription

GO
