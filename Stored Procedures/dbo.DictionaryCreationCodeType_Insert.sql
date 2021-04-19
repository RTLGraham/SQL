SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the DictionaryCreationCodeType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[DictionaryCreationCodeType_Insert]
(

	@DictionaryCreationCodeTypeId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   ,

	@LastModified datetime   
)
AS


				
				INSERT INTO [dbo].[DictionaryCreationCodeType]
					(
					[DictionaryCreationCodeTypeId]
					,[Name]
					,[Description]
					,[Archived]
					,[LastModified]
					)
				VALUES
					(
					@DictionaryCreationCodeTypeId
					,@Name
					,@Description
					,@Archived
					,@LastModified
					)
				
									
							
			


GO
