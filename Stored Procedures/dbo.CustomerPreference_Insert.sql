SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the CustomerPreference table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CustomerPreference_Insert]
(

	@CustomerPreferenceId uniqueidentifier    OUTPUT,

	@CustomerId uniqueidentifier   ,

	@NameId int   ,

	@Value nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				Declare @IdentityRowGuids table (CustomerPreferenceId uniqueidentifier	)
				INSERT INTO [dbo].[CustomerPreference]
					(
					[CustomerID]
					,[NameID]
					,[Value]
					,[Archived]
					)
						OUTPUT INSERTED.CustomerPreferenceID INTO @IdentityRowGuids
					
				VALUES
					(
					@CustomerId
					,@NameId
					,@Value
					,@Archived
					)
				
				SELECT @CustomerPreferenceId=CustomerPreferenceId	 from @IdentityRowGuids
									
							
			


GO
