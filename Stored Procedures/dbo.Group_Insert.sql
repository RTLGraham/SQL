SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the Group table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Group_Insert]
(

	@GroupId uniqueidentifier    OUTPUT,

	@GroupName nvarchar (255)  ,

	@GroupTypeId int   ,

	@IsParameter bit   ,

	@Archived bit   ,

	@LastModified datetime   ,

	@OriginalGroupId uniqueidentifier   
)
AS


				
				Declare @IdentityRowGuids table (GroupId uniqueidentifier	)
				INSERT INTO [dbo].[Group]
					(
					[GroupName]
					,[GroupTypeId]
					,[IsParameter]
					,[Archived]
					,[LastModified]
					,[OriginalGroupId]
					)
						OUTPUT INSERTED.GroupId INTO @IdentityRowGuids
					
				VALUES
					(
					@GroupName
					,@GroupTypeId
					,@IsParameter
					,@Archived
					,@LastModified
					,@OriginalGroupId
					)
				
				SELECT @GroupId=GroupId	 from @IdentityRowGuids
									
							
			


GO
