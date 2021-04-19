SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the TelcoProvider table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TelcoProvider_Update]
(

	@TelcoProviderId int   ,

	@OriginalTelcoProviderId int   ,

	@Name nvarchar (50)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[TelcoProvider]
				SET
					[TelcoProviderId] = @TelcoProviderId
					,[Name] = @Name
					,[Description] = @Description
					,[Archived] = @Archived
				WHERE
[TelcoProviderId] = @OriginalTelcoProviderId 
				
			


GO
