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


CREATE PROCEDURE [dbo].[GroupType_GetByGroupTypeName]
(

	@GroupTypeName nvarchar (255)  
)
AS


				SELECT
					[GroupTypeId],
					[GroupTypeName],
					[GroupTypeDescription]
				FROM
					[dbo].[GroupType]
				WHERE
					[GroupTypeName] = @GroupTypeName
				SELECT @@ROWCOUNT
					
			


GO
