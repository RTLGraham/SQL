SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cu_GroupDetail_AdminArchive]
(
	@groupId UNIQUEIDENTIFIER,
	@entityID UNIQUEIDENTIFIER
)
AS
	DECLARE @count INT
	SET @count = 0


	SELECT @count = COUNT(*)
	FROM dbo.GroupDetail gd
		INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
	WHERE g.IsParameter = 0 AND g.Archived = 0 
		AND gd.EntityDataId = @entityID
		AND g.GroupId != @groupId

	IF @count > 0 AND @groupId IS NOT NULL AND @entityID IS NOT NULL
	BEGIN
		DELETE FROM dbo.GroupDetail
		WHERE GroupId = @groupId AND EntityDataId = @entityID
	END
	ELSE BEGIN
		THROW 51000, 'Cannot remove the entity from the only group. Move the asset, or use copy asset first.', 1
	END

GO
