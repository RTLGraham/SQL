SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the Customer table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Customer_Update]
(

	@CustomerId uniqueidentifier   ,

	@CustomerIntId int   ,

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


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[Customer]
				SET
					[Name] = @Name
					,[Addr1] = @Addr1
					,[Addr2] = @Addr2
					,[Addr3] = @Addr3
					,[Addr4] = @Addr4
					,[Postcode] = @Postcode
					,[CountryId] = @CountryId
					,[Tel] = @Tel
					,[Fax] = @Fax
					,[LastOperation] = @LastOperation
					,[Archived] = @Archived
					,[OverSpeedValue] = @OverSpeedValue
					,[OverSpeedPercent] = @OverSpeedPercent
					,[OverSpeedHighValue] = @OverSpeedHighValue
					,[OverSpeedHighPercent] = @OverSpeedHighPercent
				WHERE
[CustomerId] = @CustomerId 
				
			


GO
