SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[User_Insert]
(

	@UserId uniqueidentifier    OUTPUT,

	@Name varchar (512)  ,

	@Password varchar (50)  ,

	@Archived bit   ,

	@Email varchar (512)  ,

	@Location nvarchar (MAX)  ,

	@FirstName nvarchar (128)  ,

	@Surname nvarchar (128)  ,

	@CustomerId uniqueidentifier ,
	
	@ExpiryDate DATETIME = NULL  
)
AS


				
				Declare @IdentityRowGuids table (UserId uniqueidentifier	)
				INSERT INTO [dbo].[User]
					(
					[Name]
					,[Password]
					,[Archived]
					,[Email]
					,[Location]
					,[FirstName]
					,[Surname]
					,[CustomerID]
					,[ExpiryDate]
					)
						OUTPUT INSERTED.UserID INTO @IdentityRowGuids
					
				VALUES
					(
					@Name
					,@Password
					,@Archived
					,@Email
					,@Location
					,@FirstName
					,@Surname
					,@CustomerId
					,@ExpiryDate
					)
				
				SELECT @UserId=UserId	 from @IdentityRowGuids

GO
