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


CREATE PROCEDURE [dbo].[IndustryType_GetByName]
(

	@Name nvarchar (255)  
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
					[Name] = @Name
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
