SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TachoMode table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TachoMode_GetByName]
(

	@Name nvarchar (255)  
)
AS


				SELECT
					[TachoModeID],
					[Name],
					[Description],
					[Archived]
				FROM
					[dbo].[TachoMode]
				WHERE
					[Name] = @Name
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
