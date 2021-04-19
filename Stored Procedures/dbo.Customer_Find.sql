SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the Customer table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Customer_Find]
(

	@SearchUsingOR bit   = null ,

	@CustomerId uniqueidentifier   = null ,

	@CustomerIntId int   = null ,

	@Name varchar (200)  = null ,

	@Addr1 varchar (200)  = null ,

	@Addr2 varchar (200)  = null ,

	@Addr3 varchar (200)  = null ,

	@Addr4 varchar (200)  = null ,

	@Postcode varchar (50)  = null ,

	@CountryId smallint   = null ,

	@Tel varchar (50)  = null ,

	@Fax varchar (50)  = null ,

	@LastOperation smalldatetime   = null ,

	@Archived bit   = null ,
	
	@OverSpeedValue INT = NULL ,
	
	@OverSpeedPercent FLOAT = NULL ,
	
	@OverSpeedHighValue INT = NULL ,
	
	@OverSpeedHighPercent FLOAT = NULL
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [CustomerId]
	, [CustomerIntId]
	, [Name]
	, [Addr1]
	, [Addr2]
	, [Addr3]
	, [Addr4]
	, [Postcode]
	, [CountryId]
	, [Tel]
	, [Fax]
	, [LastOperation]
	, [Archived]
	, [OverSpeedValue]
	, [OverSpeedPercent]
	, [OverSpeedHighValue]
	, [OverSpeedHighPercent]
    FROM
	[dbo].[Customer]
    WHERE 
	 ([CustomerId] = @CustomerId OR @CustomerId IS NULL)
	AND ([CustomerIntId] = @CustomerIntId OR @CustomerIntId IS NULL)
	AND ([Name] = @Name OR @Name IS NULL)
	AND ([Addr1] = @Addr1 OR @Addr1 IS NULL)
	AND ([Addr2] = @Addr2 OR @Addr2 IS NULL)
	AND ([Addr3] = @Addr3 OR @Addr3 IS NULL)
	AND ([Addr4] = @Addr4 OR @Addr4 IS NULL)
	AND ([Postcode] = @Postcode OR @Postcode IS NULL)
	AND ([CountryId] = @CountryId OR @CountryId IS NULL)
	AND ([Tel] = @Tel OR @Tel IS NULL)
	AND ([Fax] = @Fax OR @Fax IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND Archived = 0
	AND ([OverSpeedValue] = @OverSpeedValue OR @OverSpeedValue IS NULL)
	AND ([OverSpeedPercent] = @OverSpeedPercent OR @OverSpeedPercent IS NULL)
	AND ([OverSpeedHighValue] = @OverSpeedHighValue OR @OverSpeedHighValue IS NULL)
	AND ([OverSpeedHighPercent] = @OverSpeedHighPercent OR @OverSpeedHighPercent IS NULL)
						
  END
  ELSE
  BEGIN
    SELECT
	  [CustomerId]
	, [CustomerIntId]
	, [Name]
	, [Addr1]
	, [Addr2]
	, [Addr3]
	, [Addr4]
	, [Postcode]
	, [CountryId]
	, [Tel]
	, [Fax]
	, [LastOperation]
	, [Archived]
	, [OverSpeedValue]
	, [OverSpeedPercent]
	, [OverSpeedHighValue]
	, [OverSpeedHighPercent]
    FROM
	[dbo].[Customer]
    WHERE 
	 ([CustomerId] = @CustomerId AND @CustomerId is not null)
	OR ([CustomerIntId] = @CustomerIntId AND @CustomerIntId is not null)
	OR ([Name] = @Name AND @Name is not null)
	OR ([Addr1] = @Addr1 AND @Addr1 is not null)
	OR ([Addr2] = @Addr2 AND @Addr2 is not null)
	OR ([Addr3] = @Addr3 AND @Addr3 is not null)
	OR ([Addr4] = @Addr4 AND @Addr4 is not null)
	OR ([Postcode] = @Postcode AND @Postcode is not null)
	OR ([CountryId] = @CountryId AND @CountryId is not null)
	OR ([Tel] = @Tel AND @Tel is not null)
	OR ([Fax] = @Fax AND @Fax is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([OverSpeedValue] = @OverSpeedValue and @OverSpeedValue IS NOT NULL)
	OR ([OverSpeedPercent] = @OverSpeedPercent and @OverSpeedPercent IS not NULL)
	OR ([OverSpeedHighValue] = @OverSpeedHighValue and @OverSpeedHighValue IS not NULL)
	OR ([OverSpeedHighPercent] = @OverSpeedHighPercent and @OverSpeedHighPercent IS not NULL)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
