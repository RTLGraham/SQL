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


CREATE PROCEDURE [dbo].[Indicator_GetByIndicatorId]
(

	@IndicatorId int   
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
					[IndicatorId] = @IndicatorId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
