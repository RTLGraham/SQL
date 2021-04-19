SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the Customer table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Customer_Get_List]

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
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
