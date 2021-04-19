SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Deletes a record in the SpeedwiseCustomer table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[SpeedwiseCustomer_Delete]
(

	@CustomerDefinitionId uniqueidentifier   
)
AS


				    DELETE FROM [dbo].[SpeedwiseCustomer] WITH (ROWLOCK) 
				WHERE
					[CustomerDefinitionID] = @CustomerDefinitionId
					
			


GO
