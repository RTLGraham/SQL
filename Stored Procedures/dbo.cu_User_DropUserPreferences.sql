SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[cu_User_DropUserPreferences]
    (
      @userId UNIQUEIDENTIFIER   
    )
AS 
    DELETE  FROM dbo.UserPreference
    WHERE   UserID = @userId


GO
