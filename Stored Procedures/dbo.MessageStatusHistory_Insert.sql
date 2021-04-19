SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the MessageStatusHistory table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageStatusHistory_Insert]
(

	@MessageStatusHistoryId int    OUTPUT,

	@MessageId int   ,

	@MessageStatusId int   ,

	@LastModified datetime   
)
AS


				
				INSERT INTO [dbo].[MessageStatusHistory]
					(
					[MessageId]
					,[MessageStatusId]
					,[LastModified]
					)
				VALUES
					(
					@MessageId
					,@MessageStatusId
					,@LastModified
					)
				
				-- Get the identity value
				SET @MessageStatusHistoryId = SCOPE_IDENTITY()
									
							
			


GO
