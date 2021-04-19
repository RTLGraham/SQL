SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the MessageStatus table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageStatus_Insert]
(

	@MessageStatusId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[MessageStatus]
					(
					[MessageStatusId]
					,[Name]
					,[Description]
					,[Archived]
					)
				VALUES
					(
					@MessageStatusId
					,@Name
					,@Description
					,@Archived
					)
				
									
							
			


GO
