SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the Group table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Group_Update]
(

	@GroupId uniqueidentifier   ,

	@GroupName nvarchar (255)  ,

	@GroupTypeId int   ,

	@IsParameter bit   ,

	@Archived bit   ,

	@LastModified datetime   ,

	@OriginalGroupId uniqueidentifier   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[Group]
				SET
					[GroupName] = @GroupName
					,[GroupTypeId] = @GroupTypeId
					,[IsParameter] = @IsParameter
					,[Archived] = @Archived
					,[LastModified] = @LastModified
					,[OriginalGroupId] = @OriginalGroupId
				WHERE
[GroupId] = @GroupId 
				
			


GO
