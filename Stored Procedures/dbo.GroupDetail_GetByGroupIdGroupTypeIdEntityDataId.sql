SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the GroupDetail table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupDetail_GetByGroupIdGroupTypeIdEntityDataId]
(

	@GroupId uniqueidentifier   ,

	@GroupTypeId int   ,

	@EntityDataId uniqueidentifier   
)
AS


				SELECT
					[GroupId],
					[GroupTypeId],
					[EntityDataId]
				FROM
					[dbo].[GroupDetail]
				WHERE
					[GroupId] = @GroupId
					AND [GroupTypeId] = @GroupTypeId
					AND [EntityDataId] = @EntityDataId
				SELECT @@ROWCOUNT
					
			


GO
