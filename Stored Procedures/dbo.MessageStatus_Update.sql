SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the MessageStatus table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageStatus_Update]
(

	@MessageStatusId int   ,

	@OriginalMessageStatusId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[MessageStatus]
				SET
					[MessageStatusId] = @MessageStatusId
					,[Name] = @Name
					,[Description] = @Description
					,[Archived] = @Archived
				WHERE
[MessageStatusId] = @OriginalMessageStatusId 
				
			


GO
