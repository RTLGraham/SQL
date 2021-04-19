SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the IndicatorConfig table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[IndicatorConfig_GetByIndicatorId]
(

	@IndicatorId int   
)
AS


				SET ANSI_NULLS OFF
				
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
                            [IndicatorId] = @IndicatorId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
