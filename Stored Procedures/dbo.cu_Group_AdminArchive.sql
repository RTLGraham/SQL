SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_Group_AdminArchive]
(
	@groupId UNIQUEIDENTIFIER
)
AS
	UPDATE dbo.[Group]
	SET Archived = 1
	WHERE GroupId = @groupId

GO
