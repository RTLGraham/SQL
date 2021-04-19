SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cu_User_CreateNewUser]
    (
      @Name VARCHAR(512),
      @Password VARCHAR(50),
      @Email VARCHAR(512),
      @FirstName NVARCHAR(128),
      @Surname NVARCHAR(128),
      @CustomerID UNIQUEIDENTIFIER,
      @ExpiryDate DATETIME = NULL
    )
AS 
    DECLARE @UserID UNIQUEIDENTIFIER
    SET @UserID = NEWID()
	
	DECLARE @input VARBINARY(64)
	SET @input = HASHBYTES('SHA2_512', 'hash'+CAST(@name as VARCHAR(512))+'salt'+CAST(@password as VARCHAR(50))+'pepper')

    INSERT  INTO dbo.[User]
            (
              [UserId],
              [Name],
              [Password],
              [Archived],
              [Email],
              [FirstName],
              [Surname],
              [CustomerId],
              [ExpiryDate],
			  [PasswordHash]
            )
    VALUES  (
              @UserID,
              @Name,
              '',--@Password,
              0,
              @Email,
              @FirstName,
              @Surname,
              @CustomerID,
              @ExpiryDate,
	          @input
            )
	        
	 
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
