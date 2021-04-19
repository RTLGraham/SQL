SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the Driver table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Driver_Insert]
(

	@DriverId uniqueidentifier    OUTPUT,

	@DriverIntId int    OUTPUT,

	@Number varchar (32)  ,

	@NumberAlternate varchar (32)  ,

	@NumberAlternate2 varchar (32)  ,

	@FirstName varchar (50)  ,

	@Surname varchar (50)  ,

	@MiddleNames varchar (250)  ,

	@LastOperation smalldatetime   ,

	@Archived bit   
)
AS


				
				Declare @IdentityRowGuids table (DriverId uniqueidentifier	)
				INSERT INTO [dbo].[Driver]
					(
					[Number]
					,[NumberAlternate]
					,[NumberAlternate2]
					,[FirstName]
					,[Surname]
					,[MiddleNames]
					,[LastOperation]
					,[Archived]
					)
						OUTPUT INSERTED.DriverId INTO @IdentityRowGuids
					
				VALUES
					(
					@Number
					,@NumberAlternate
					,@NumberAlternate2
					,@FirstName
					,@Surname
					,@MiddleNames
					,@LastOperation
					,@Archived
					)
				
				SELECT @DriverId=DriverId	 from @IdentityRowGuids
				-- Get the identity value
				SET @DriverIntId = SCOPE_IDENTITY()
									
							
			


GO
