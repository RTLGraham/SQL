SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the WKD_WorkDiaryPage table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiaryPage_Insert]
(

	@WorkDiaryPageId int    OUTPUT,

	@WorkDiaryId int   ,

	@Date smalldatetime   ,

	@DriverSignature image   ,

	@SignDate datetime   ,

	@TwoUpWorkDiaryPageId int   ,

	@Archived bit   ,

	@LastOperation smalldatetime   
)
AS


				
				INSERT INTO [dbo].[WKD_WorkDiaryPage]
					(
					[WorkDiaryId]
					,[Date]
					,[DriverSignature]
					,[SignDate]
					,[TwoUpWorkDiaryPageId]
					,[Archived]
					,[LastOperation]
					)
				VALUES
					(
					@WorkDiaryId
					,@Date
					,@DriverSignature
					,@SignDate
					,@TwoUpWorkDiaryPageId
					,@Archived
					,@LastOperation
					)
				
				-- Get the identity value
				SET @WorkDiaryPageId = SCOPE_IDENTITY()
									
							
			


GO
