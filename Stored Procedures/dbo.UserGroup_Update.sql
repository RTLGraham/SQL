SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the UserGroup table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[UserGroup_Update]
(

	@UserId uniqueidentifier   ,

	@OriginalUserId uniqueidentifier   ,

	@GroupId uniqueidentifier   ,

	@OriginalGroupId uniqueidentifier   ,

	@Archived bit   ,

	@LastModified datetime   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[UserGroup]
				SET
					[UserId] = @UserId
					,[GroupId] = @GroupId
					,[Archived] = @Archived
					,[LastModified] = @LastModified
				WHERE
[UserId] = @OriginalUserId 
AND [GroupId] = @OriginalGroupId 
				
			


GO
