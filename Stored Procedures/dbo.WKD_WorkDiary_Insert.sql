SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the WKD_WorkDiary table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkDiary_Insert]
(

	@WorkDiaryId int    OUTPUT,

	@DriverIntId int   ,

	@StartDate datetime   ,

	@Number varchar (20)  ,

	@EndDate datetime   ,

	@Archived bit   ,

	@LastOperation smalldatetime   
)
AS


				
				INSERT INTO [dbo].[WKD_WorkDiary]
					(
					[DriverIntId]
					,[StartDate]
					,[Number]
					,[EndDate]
					,[Archived]
					,[LastOperation]
					)
				VALUES
					(
					@DriverIntId
					,@StartDate
					,@Number
					,@EndDate
					,@Archived
					,@LastOperation
					)
				
				-- Get the identity value
				SET @WorkDiaryId = SCOPE_IDENTITY()
									
							
			


GO
