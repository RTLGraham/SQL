SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the Customer table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Customer_Insert]
(

	@CustomerId uniqueidentifier    OUTPUT,

	@CustomerIntId int    OUTPUT,

	@Name varchar (200)  ,

	@Addr1 varchar (200)  ,

	@Addr2 varchar (200)  ,

	@Addr3 varchar (200)  ,

	@Addr4 varchar (200)  ,

	@Postcode varchar (50)  ,

	@CountryId smallint   ,

	@Tel varchar (50)  ,

	@Fax varchar (50)  ,

	@LastOperation smalldatetime   ,

	@Archived bit ,
	
	@OverSpeedValue INT = NULL ,
	
	@OverSpeedPercent FLOAT = NULL ,
	
	@OverSpeedHighValue INT = NULL ,
	
	@OverSpeedHighPercent FLOAT = NULL
)
AS


				
				Declare @IdentityRowGuids table (CustomerId uniqueidentifier	)
				INSERT INTO [dbo].[Customer]
					(
					[Name]
					,[Addr1]
					,[Addr2]
					,[Addr3]
					,[Addr4]
					,[Postcode]
					,[CountryId]
					,[Tel]
					,[Fax]
					,[LastOperation]
					,[Archived]
					,[OverSpeedValue]
					,[OverSpeedPercent]
					,[OverSpeedHighValue]
					,[OverSpeedHighPercent]
					)
						OUTPUT INSERTED.CustomerId INTO @IdentityRowGuids
					
				VALUES
					(
					@Name
					,@Addr1
					,@Addr2
					,@Addr3
					,@Addr4
					,@Postcode
					,@CountryId
					,@Tel
					,@Fax
					,@LastOperation
					,@Archived
					,@OverSpeedValue
					,@OverSpeedPercent
					,@OverSpeedHighValue
					,@OverSpeedHighPercent
					)
				
				SELECT @CustomerId=CustomerId	 from @IdentityRowGuids
				-- Get the identity value
				SET @CustomerIntId = SCOPE_IDENTITY()
									
							
			


GO
