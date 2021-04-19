SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the SpeedwiseCustomer table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[SpeedwiseCustomer_GetByCustomerDefinitionId]
(

	@CustomerDefinitionId uniqueidentifier   
)
AS


				SELECT
					[CustomerDefinitionID],
					[CustomerId],
					[Treshhold]
				FROM
					[dbo].[SpeedwiseCustomer]
				WHERE
					[CustomerDefinitionID] = @CustomerDefinitionId
				SELECT @@ROWCOUNT
					
			


GO
