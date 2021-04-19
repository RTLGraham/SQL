SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the ChartType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[ChartType_Get_List]

AS


				
				SELECT
					[ChartTypeId],
					[Name],
					[Description],
					[LastModified],
					[Archived]
				FROM
					[dbo].[ChartType]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
