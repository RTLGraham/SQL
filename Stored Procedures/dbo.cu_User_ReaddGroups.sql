SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[cu_User_ReaddGroups]
    (
      @userId UNIQUEIDENTIFIER,
      @groupType INT,
      @groups NVARCHAR(MAX)
    )
AS 
    DELETE  ug
    FROM    dbo.UserGroup ug
            INNER JOIN dbo.[Group] g ON ug.GroupId = g.GroupId
    WHERE   ug.UserID = @userId
            AND g.GroupTypeId = @groupType
		
    INSERT  INTO dbo.UserGroup
            (
              UserId,
              GroupId,
              Archived,
              LastModified
            )
            SELECT  @userId,
                    Value,
                    0,
                    GETDATE()
            FROM    dbo.Split(@groups, ',')

GO
