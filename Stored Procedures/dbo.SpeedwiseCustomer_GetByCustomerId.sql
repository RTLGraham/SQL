SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the SpeedwiseCustomer table through a foreign key
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[SpeedwiseCustomer_GetByCustomerId]
(

	@CustomerId uniqueidentifier   
)
AS


				SET ANSI_NULLS OFF
				
				SELECT
					[CustomerDefinitionID],
					[CustomerId],
					[Treshhold]
				FROM
					[dbo].[SpeedwiseCustomer]
				WHERE
                            [CustomerId] = @CustomerId
				
				SELECT @@ROWCOUNT
				SET ANSI_NULLS ON
			


GO
