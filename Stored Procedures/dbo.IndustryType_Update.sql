SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the IndustryType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[IndustryType_Update]
(

	@IndustryTypeId int   ,

	@OriginalIndustryTypeId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[IndustryType]
				SET
					[IndustryTypeId] = @IndustryTypeId
					,[Name] = @Name
					,[Description] = @Description
					,[Archived] = @Archived
				WHERE
[IndustryTypeId] = @OriginalIndustryTypeId 
				
			


GO
