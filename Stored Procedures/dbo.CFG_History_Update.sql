SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the CFG_History table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_History_Update]
(

	@HistoryId int   ,

	@IvhIntId int   ,

	@KeyId int   ,

	@KeyValue nvarchar (MAX)  ,

	@StartDate datetime   ,

	@EndDate datetime   ,

	@Status bit   ,

	@LastOperation smalldatetime   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[CFG_History]
				SET
					[IVHIntId] = @IvhIntId
					,[KeyId] = @KeyId
					,[KeyValue] = @KeyValue
					,[StartDate] = @StartDate
					,[EndDate] = @EndDate
					,[Status] = @Status
					,[LastOperation] = @LastOperation
				WHERE
[HistoryId] = @HistoryId 
				
			


				
			


GO
