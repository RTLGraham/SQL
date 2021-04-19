SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the Customer table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Customer_GetByCustomerIntId]
(

	@CustomerIntId int   
)
AS


				SELECT
					[CustomerId],
					[CustomerIntId],
					[Name],
					[Addr1],
					[Addr2],
					[Addr3],
					[Addr4],
					[Postcode],
					[CountryId],
					[Tel],
					[Fax],
					[LastOperation],
					[Archived],
					[OverSpeedValue],
					[OverSpeedPercent],
					[OverSpeedHighValue],
					[OverSpeedHighPercent]
				FROM
					[dbo].[Customer]
				WHERE
					[CustomerIntId] = @CustomerIntId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
