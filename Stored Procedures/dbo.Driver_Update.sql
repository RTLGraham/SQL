SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the Driver table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Driver_Update]
(

	@DriverId uniqueidentifier   ,

	@DriverIntId int   ,

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


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[Driver]
				SET
					[Number] = @Number
					,[NumberAlternate] = @NumberAlternate
					,[NumberAlternate2] = @NumberAlternate2
					,[FirstName] = @FirstName
					,[Surname] = @Surname
					,[MiddleNames] = @MiddleNames
					,[LastOperation] = @LastOperation
					,[Archived] = @Archived
				WHERE
[DriverId] = @DriverId 
				
			


GO
