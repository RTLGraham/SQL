SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the UserGroup table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserGroup_Insert]
(

	@UserId uniqueidentifier   ,

	@GroupId uniqueidentifier   ,

	@Archived bit   ,

	@LastModified datetime   
)
AS


				
				INSERT INTO [dbo].[UserGroup]
					(
					[UserId]
					,[GroupId]
					,[Archived]
					,[LastModified]
					)
				VALUES
					(
					@UserId
					,@GroupId
					,@Archived
					,@LastModified
					)
				
									
							
			


GO
