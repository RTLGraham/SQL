SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the SpeedwiseCustomer table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[SpeedwiseCustomer_Insert]
(

	@CustomerDefinitionId uniqueidentifier    OUTPUT,

	@CustomerId uniqueidentifier   ,

	@Treshhold float   
)
AS


				
				Declare @IdentityRowGuids table (CustomerDefinitionId uniqueidentifier	)
				INSERT INTO [dbo].[SpeedwiseCustomer]
					(
					[CustomerId]
					,[Treshhold]
					)
						OUTPUT INSERTED.CustomerDefinitionID INTO @IdentityRowGuids
					
				VALUES
					(
					@CustomerId
					,@Treshhold
					)
				
				SELECT @CustomerDefinitionId=CustomerDefinitionId	 from @IdentityRowGuids
									
							
			


GO
