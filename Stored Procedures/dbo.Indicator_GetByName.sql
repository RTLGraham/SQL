SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the Indicator table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Indicator_GetByName]
(

	@Name varchar (100)  
)
AS


				SELECT
					[IndicatorId],
					[Name],
					[Description],
					[Archived],
					[HighLow],
					[Parameter],
					[Type],
					[LastModified],
					[IndicatorClass],
					[Rounding],
					[DisplaySeq]
				FROM
					[dbo].[Indicator]
				WHERE
					[Name] = @Name
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
