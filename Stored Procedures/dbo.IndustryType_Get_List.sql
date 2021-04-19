SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the IndustryType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[IndustryType_Get_List]

AS


				
				SELECT
					[IndustryTypeId],
					[Name],
					[Description],
					[Archived]
				FROM
					[dbo].[IndustryType]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
