SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the Indicator table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Indicator_Get_List]

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
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
