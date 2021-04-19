SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the GroupDetail table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupDetail_Update]
(

	@GroupId uniqueidentifier   ,

	@OriginalGroupId uniqueidentifier   ,

	@GroupTypeId int   ,

	@OriginalGroupTypeId int   ,

	@EntityDataId uniqueidentifier   ,

	@OriginalEntityDataId uniqueidentifier   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[GroupDetail]
				SET
					[GroupId] = @GroupId
					,[GroupTypeId] = @GroupTypeId
					,[EntityDataId] = @EntityDataId
				WHERE
[GroupId] = @OriginalGroupId 
AND [GroupTypeId] = @OriginalGroupTypeId 
AND [EntityDataId] = @OriginalEntityDataId 
				
			


GO
