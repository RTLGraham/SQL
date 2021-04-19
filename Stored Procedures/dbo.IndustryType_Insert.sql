SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the IndustryType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[IndustryType_Insert]
(

	@IndustryTypeId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[IndustryType]
					(
					[IndustryTypeId]
					,[Name]
					,[Description]
					,[Archived]
					)
				VALUES
					(
					@IndustryTypeId
					,@Name
					,@Description
					,@Archived
					)
				
									
							
			


GO
