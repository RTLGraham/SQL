SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the CFG_History table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_History_Insert]
(

	@HistoryId int    OUTPUT,

	@IvhIntId int   ,

	@KeyId int   ,

	@KeyValue nvarchar (MAX)  ,

	@StartDate datetime   ,

	@EndDate datetime   ,

	@Status bit   ,

	@LastOperation smalldatetime   
)
AS


				
				INSERT INTO [dbo].[CFG_History]
					(
					[IVHIntId]
					,[KeyId]
					,[KeyValue]
					,[StartDate]
					,[EndDate]
					,[Status]
					,[LastOperation]
					)
				VALUES
					(
					@IvhIntId
					,@KeyId
					,@KeyValue
					,@StartDate
					,@EndDate
					,@Status
					,@LastOperation
					)
				
				-- Get the identity value
				SET @HistoryId = SCOPE_IDENTITY()
									
							
			


GO
