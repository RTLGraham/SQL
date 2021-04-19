SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the GroupDetail table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupDetail_Delete]
(

	@GroupId uniqueidentifier   ,

	@GroupTypeId int   ,

	@EntityDataId uniqueidentifier   
)
AS


				    DELETE FROM [dbo].[GroupDetail] WITH (ROWLOCK) 
				WHERE
					[GroupId] = @GroupId
					AND [GroupTypeId] = @GroupTypeId
					AND [EntityDataId] = @EntityDataId
					
			


GO
