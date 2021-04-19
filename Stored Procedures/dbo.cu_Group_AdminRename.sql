SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_Group_AdminRename]
(
	@groupId UNIQUEIDENTIFIER,
	@newName NVARCHAR(255)
)
AS
	UPDATE dbo.[Group]
	SET GroupName = @newName
	WHERE GroupId = @groupId

GO
