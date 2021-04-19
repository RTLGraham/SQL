SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the GroupDetail table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupDetail_GetByGroupId]
(

	@GroupId uniqueidentifier   
)
AS


				SET ANSI_NULLS OFF
				
				SELECT
					[GroupId],
					[GroupTypeId],
					[EntityDataId]
				FROM
					[dbo].[GroupDetail]
				WHERE
                            [GroupId] = @GroupId
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
