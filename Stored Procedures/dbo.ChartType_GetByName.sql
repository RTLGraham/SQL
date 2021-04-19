SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the ChartType table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[ChartType_GetByName]
(

	@Name nvarchar (255)  
)
AS


				SELECT
					[ChartTypeId],
					[Name],
					[Description],
					[LastModified],
					[Archived]
				FROM
					[dbo].[ChartType]
				WHERE
					[Name] = @Name
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
