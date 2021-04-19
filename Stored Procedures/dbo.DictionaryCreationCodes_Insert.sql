SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the DictionaryCreationCodes table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DictionaryCreationCodes_Insert]
(

	@CreationCodeId smallint   ,

	@DictionaryNameId int   ,

	@DictionaryCreationCodeTypeId int   
)
AS


				
				INSERT INTO [dbo].[DictionaryCreationCodes]
					(
					[CreationCodeId]
					,[DictionaryNameId]
					,[DictionaryCreationCodeTypeId]
					)
				VALUES
					(
					@CreationCodeId
					,@DictionaryNameId
					,@DictionaryCreationCodeTypeId
					)
				
									
							
			


GO
