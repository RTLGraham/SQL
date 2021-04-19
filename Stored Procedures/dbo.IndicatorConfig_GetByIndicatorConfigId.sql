SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the IndicatorConfig table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[IndicatorConfig_GetByIndicatorConfigId]
(

	@IndicatorConfigId int   
)
AS


				SELECT
					[IndicatorConfigId],
					[IndicatorId],
					[ReportConfigurationId],
					[Min],
					[Max],
					[Weight],
					[GYRGreenMax],
					[GYRAmberMax],
					[Target],
					[Archived],
					[LastModified],
					[GYRRedMax]
				FROM
					[dbo].[IndicatorConfig]
				WHERE
					[IndicatorConfigId] = @IndicatorConfigId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
