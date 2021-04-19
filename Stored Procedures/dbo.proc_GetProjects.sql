SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_GetProjects]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	ApiPassword,
			ApiUrl,
			ApiUser,
			CustomerId,
			LastIncidentId,
			Project
	FROM dbo.Project
	WHERE Archived = 0
END



GO
