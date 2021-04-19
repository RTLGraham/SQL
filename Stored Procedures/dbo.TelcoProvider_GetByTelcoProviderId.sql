SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the TelcoProvider table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TelcoProvider_GetByTelcoProviderId]
(

	@TelcoProviderId int   
)
AS


				SELECT
					[TelcoProviderId],
					[Name],
					[Description],
					[Archived]
				FROM
					[dbo].[TelcoProvider]
				WHERE
					[TelcoProviderId] = @TelcoProviderId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			


GO
