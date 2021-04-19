SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[User_Find]
(

	@SearchUsingOR bit   = null ,

	@UserId uniqueidentifier   = null ,

	@Name varchar (512)  = null ,

	@Password varchar (50)  = null ,

	@Archived bit   = null ,

	@Email varchar (512)  = null ,

	@Location nvarchar (MAX)  = null ,

	@FirstName nvarchar (128)  = null ,

	@Surname nvarchar (128)  = null ,

	@CustomerId uniqueidentifier   = null ,
	
	@ExpiryDate DATETIME = NULL 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [UserID]
	, [Name]
	, [Password]
	, [Archived]
	, [Email]
	, [Location]
	, [FirstName]
	, [Surname]
	, [CustomerID]
	, [ExpiryDate]
    FROM
	[dbo].[User]
    WHERE 
	 ([UserID] = @UserId OR @UserId IS NULL)
	AND ([Name] = @Name OR @Name IS NULL)
	AND ([Password] = @Password OR @Password IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([Email] = @Email OR @Email IS NULL)
	AND ([Location] = @Location OR @Location IS NULL)
	AND ([FirstName] = @FirstName OR @FirstName IS NULL)
	AND ([Surname] = @Surname OR @Surname IS NULL)
	AND ([CustomerID] = @CustomerId OR @CustomerId IS NULL)
	AND ([ExpiryDate] = @ExpiryDate OR @ExpiryDate is NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [UserID]
	, [Name]
	, [Password]
	, [Archived]
	, [Email]
	, [Location]
	, [FirstName]
	, [Surname]
	, [CustomerID]
	, [ExpiryDate]
    FROM
	[dbo].[User]
    WHERE 
	 ([UserID] = @UserId AND @UserId is not null)
	OR ([Name] = @Name AND @Name is not null)
	OR ([Password] = @Password AND @Password is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([Email] = @Email AND @Email is not null)
	OR ([Location] = @Location AND @Location is not null)
	OR ([FirstName] = @FirstName AND @FirstName is not null)
	OR ([Surname] = @Surname AND @Surname is not null)
	OR ([CustomerID] = @CustomerId AND @CustomerId is not null)
	OR ([ExpiryDate] = @ExpiryDate AND @ExpiryDate is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END

GO
