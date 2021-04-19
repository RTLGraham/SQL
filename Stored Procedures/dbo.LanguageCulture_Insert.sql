SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the LanguageCulture table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[LanguageCulture_Insert]
(

	@LanguageCultureId smallint    OUTPUT,

	@Name nvarchar (255)  ,

	@Code nvarchar (20)  ,

	@Description nvarchar (MAX)  ,

	@HardwareIndex smallint   ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[LanguageCulture]
					(
					[Name]
					,[Code]
					,[Description]
					,[HardwareIndex]
					,[Archived]
					)
				VALUES
					(
					@Name
					,@Code
					,@Description
					,@HardwareIndex
					,@Archived
					)
				
				-- Get the identity value
				SET @LanguageCultureId = SCOPE_IDENTITY()
									
							
			


GO
