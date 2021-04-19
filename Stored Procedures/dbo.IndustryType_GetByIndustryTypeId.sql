SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the IndustryType table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[IndustryType_GetByIndustryTypeId]
(

	@IndustryTypeId int   
)
AS


				SELECT
					[IndustryTypeId],
					[Name],
					[Description],
					[Archived]
				FROM
					[dbo].[IndustryType]
				WHERE
					[IndustryTypeId] = @IndustryTypeId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
