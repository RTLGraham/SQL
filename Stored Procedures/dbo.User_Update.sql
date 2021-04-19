SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the User table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[User_Update]
(

	@UserId uniqueidentifier   ,

	@Name varchar (512)  ,

	@Password varchar (50)  ,

	@Archived bit   ,

	@Email varchar (512)  ,

	@Location nvarchar (MAX)  ,

	@FirstName nvarchar (128)  ,

	@Surname nvarchar (128)  ,

	@CustomerId uniqueidentifier   ,
	
	@ExpiryDate DATETIME = NULL
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[User]
				SET
					[Name] = @Name
					,[Password] = @Password
					,[Archived] = @Archived
					,[Email] = @Email
					,[Location] = @Location
					,[FirstName] = @FirstName
					,[Surname] = @Surname
					,[CustomerID] = @CustomerId
					,[ExpiryDate] = @ExpiryDate
				WHERE
[UserID] = @UserId 

GO
