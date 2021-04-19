SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[cu_User_ArchiveUser]
    (
	  @UserID UNIQUEIDENTIFIER
    )
AS 
    UPDATE dbo.[User]
    SET [Archived] = 1
	WHERE [UserID] = @UserID

GO
