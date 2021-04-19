SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the GroupType table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupType_GetByGroupTypeId]
(

	@GroupTypeId int   
)
AS


				SELECT
					[GroupTypeId],
					[GroupTypeName],
					[GroupTypeDescription]
				FROM
					[dbo].[GroupType]
				WHERE
					[GroupTypeId] = @GroupTypeId
				SELECT @@ROWCOUNT
					
			


GO
