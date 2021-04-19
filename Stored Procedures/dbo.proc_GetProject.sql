SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_GetProject] @cid UNIQUEIDENTIFIER
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
	WHERE CustomerId = @cid
END



GO
