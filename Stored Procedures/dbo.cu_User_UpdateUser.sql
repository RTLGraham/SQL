SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cu_User_UpdateUser]
    (
	  @UserID UNIQUEIDENTIFIER,
      @Name VARCHAR(512),
      @Password VARCHAR(50),
      @Email VARCHAR(512),
      @FirstName NVARCHAR(128),
      @Surname NVARCHAR(128),
      @CustomerID UNIQUEIDENTIFIER,
      @ExpiryDate DATETIME = NULL
    )
AS 

    UPDATE dbo.[User]
    SET
              [Name] = @Name,
              --[Password] = @Password,
              [Archived] = 0,
              [Email] = @Email,
              [FirstName] = @FirstName,
              [Surname] = @Surname,
              [CustomerID] = @CustomerID,
              [ExpiryDate] = @ExpiryDate
	WHERE [UserID] = @UserID
	        
	 
    SELECT  [UserId],
            [Name],
            '' as [Password],
            [Archived],
            [Email],
            [Location],
            [FirstName],
            [Surname],
            [CustomerId],
            [ExpiryDate]
    FROM    [dbo].[User]
    WHERE   UserID = @UserID

GO
