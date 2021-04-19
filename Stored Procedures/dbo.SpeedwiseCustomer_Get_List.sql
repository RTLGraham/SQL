SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the SpeedwiseCustomer table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[SpeedwiseCustomer_Get_List]

AS


				
				SELECT
					[CustomerDefinitionID],
					[CustomerId],
					[Treshhold]
				FROM
					[dbo].[SpeedwiseCustomer]

				SELECT @@ROWCOUNT
			


GO
