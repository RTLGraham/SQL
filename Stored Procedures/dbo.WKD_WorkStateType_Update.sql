SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the WKD_WorkStateType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkStateType_Update]
(

	@WorkStateTypeId int   ,

	@OriginalWorkStateTypeId int   ,

	@Name varchar (50)  ,

	@Description varchar (MAX)  ,

	@LastModified datetime   ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[WKD_WorkStateType]
				SET
					[WorkStateTypeId] = @WorkStateTypeId
					,[Name] = @Name
					,[Description] = @Description
					,[LastModified] = @LastModified
					,[Archived] = @Archived
				WHERE
[WorkStateTypeId] = @OriginalWorkStateTypeId 
				
			


GO
