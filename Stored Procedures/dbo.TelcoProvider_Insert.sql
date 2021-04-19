SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the TelcoProvider table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TelcoProvider_Insert]
(

	@TelcoProviderId int   ,

	@Name nvarchar (50)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[TelcoProvider]
					(
					[TelcoProviderId]
					,[Name]
					,[Description]
					,[Archived]
					)
				VALUES
					(
					@TelcoProviderId
					,@Name
					,@Description
					,@Archived
					)
				
									
							
			


GO
