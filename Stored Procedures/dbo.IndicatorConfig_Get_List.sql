SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the IndicatorConfig table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[IndicatorConfig_Get_List]

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
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
