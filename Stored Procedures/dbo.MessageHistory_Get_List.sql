SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the MessageHistory table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageHistory_Get_List]

AS


				
				SELECT
					[MessageId],
					[MessageText],
					[Lat],
					[Long],
					[ReverseGeocode],
					[Date],
					[LastModified],
					[Archived]
				FROM
					[dbo].[MessageHistory]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
