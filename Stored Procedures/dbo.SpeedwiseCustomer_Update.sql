SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the SpeedwiseCustomer table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[SpeedwiseCustomer_Update]
(

	@CustomerDefinitionId uniqueidentifier   ,

	@CustomerId uniqueidentifier   ,

	@Treshhold float   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[SpeedwiseCustomer]
				SET
					[CustomerId] = @CustomerId
					,[Treshhold] = @Treshhold
				WHERE
[CustomerDefinitionID] = @CustomerDefinitionId 
				
			


GO
