SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the WKD_WorkDiaryPage table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiaryPage_Update]
(

	@WorkDiaryPageId int   ,

	@WorkDiaryId int   ,

	@Date smalldatetime   ,

	@DriverSignature image   ,

	@SignDate datetime   ,

	@TwoUpWorkDiaryPageId int   ,

	@Archived bit   ,

	@LastOperation smalldatetime   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[WKD_WorkDiaryPage]
				SET
					[WorkDiaryId] = @WorkDiaryId
					,[Date] = @Date
					,[DriverSignature] = @DriverSignature
					,[SignDate] = @SignDate
					,[TwoUpWorkDiaryPageId] = @TwoUpWorkDiaryPageId
					,[Archived] = @Archived
					,[LastOperation] = @LastOperation
				WHERE
[WorkDiaryPageId] = @WorkDiaryPageId 
				
			


GO
