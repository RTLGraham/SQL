SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the MessageStatusHistory table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageStatusHistory_Update]
(

	@MessageStatusHistoryId int   ,

	@MessageId int   ,

	@MessageStatusId int   ,

	@LastModified datetime   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[MessageStatusHistory]
				SET
					[MessageId] = @MessageId
					,[MessageStatusId] = @MessageStatusId
					,[LastModified] = @LastModified
				WHERE
[MessageStatusHistoryId] = @MessageStatusHistoryId 
				
			


GO
