SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the GroupType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupType_Update]
(

	@GroupTypeId int   ,

	@OriginalGroupTypeId int   ,

	@GroupTypeName nvarchar (255)  ,

	@GroupTypeDescription nvarchar (MAX)  
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[GroupType]
				SET
					[GroupTypeId] = @GroupTypeId
					,[GroupTypeName] = @GroupTypeName
					,[GroupTypeDescription] = @GroupTypeDescription
				WHERE
[GroupTypeId] = @OriginalGroupTypeId 
				
			


GO
