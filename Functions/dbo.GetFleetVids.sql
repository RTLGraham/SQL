SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[GetFleetVids]
(
	@uid UNIQUEIDENTIFIER
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @Fleetvids VARCHAR(MAX)
	
	SELECT @Fleetvids = COALESCE(@Fleetvids + ',', '') + CAST(gd.EntityDataId AS VARCHAR(MAX))
	FROM dbo.UserGroup ug
	INNER JOIN dbo.GroupDetail gd ON ug.GroupId = gd.GroupId
	WHERE ug.UserId = @uid	
	  AND ug.Archived = 0 
	  AND gd.GroupTypeId = 1

	RETURN @Fleetvids
END

GO
