SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the GroupDetail table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupDetail_Get_List]

AS


				
				SELECT
					[GroupId],
					[GroupTypeId],
					[EntityDataId]
				FROM
					[dbo].[GroupDetail]

				SELECT @@ROWCOUNT
			


GO
