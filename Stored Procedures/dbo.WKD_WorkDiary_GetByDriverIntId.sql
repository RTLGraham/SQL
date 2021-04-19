SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the WKD_WorkDiary table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiary_GetByDriverIntId]
(

	@DriverIntId int   
)
AS


				SET ANSI_NULLS OFF
				
				SELECT
					[WorkDiaryId],
					[DriverIntId],
					[StartDate],
					[Number],
					[EndDate],
					[Archived],
					[LastOperation]
				FROM
					[dbo].[WKD_WorkDiary]
				WHERE
                            [DriverIntId] = @DriverIntId
                                AND
                            Archived = 0
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
