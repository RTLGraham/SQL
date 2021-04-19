SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the LanguageCulture table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[LanguageCulture_Update]
(

	@LanguageCultureId smallint   ,

	@Name nvarchar (255)  ,

	@Code nvarchar (20)  ,

	@Description nvarchar (MAX)  ,

	@HardwareIndex smallint   ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[LanguageCulture]
				SET
					[Name] = @Name
					,[Code] = @Code
					,[Description] = @Description
					,[HardwareIndex] = @HardwareIndex
					,[Archived] = @Archived
				WHERE
[LanguageCultureID] = @LanguageCultureId 
				
			


GO
