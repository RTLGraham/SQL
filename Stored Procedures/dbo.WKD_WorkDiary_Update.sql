SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the WKD_WorkDiary table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiary_Update]
(

	@WorkDiaryId int   ,

	@DriverIntId int   ,

	@StartDate datetime   ,

	@Number varchar (20)  ,

	@EndDate datetime   ,

	@Archived bit   ,

	@LastOperation smalldatetime   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[WKD_WorkDiary]
				SET
					[DriverIntId] = @DriverIntId
					,[StartDate] = @StartDate
					,[Number] = @Number
					,[EndDate] = @EndDate
					,[Archived] = @Archived
					,[LastOperation] = @LastOperation
				WHERE
[WorkDiaryId] = @WorkDiaryId 
				
			


GO
