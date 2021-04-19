SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the CustomerPreference table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CustomerPreference_Update]
(

	@CustomerPreferenceId uniqueidentifier   ,

	@CustomerId uniqueidentifier   ,

	@NameId int   ,

	@Value nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[CustomerPreference]
				SET
					[CustomerID] = @CustomerId
					,[NameID] = @NameId
					,[Value] = @Value
					,[Archived] = @Archived
				WHERE
[CustomerPreferenceID] = @CustomerPreferenceId 
				
			


GO
