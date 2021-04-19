SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the TAN_TriggerType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerType_Insert]
(

	@TriggerTypeId int   ,

	@Name varchar (255)  ,

	@Description varchar (MAX)  ,

	@CreationCodeId smallint   ,

	@Archived bit   ,

	@LastOperation smalldatetime   
)
AS


				
				INSERT INTO [dbo].[TAN_TriggerType]
					(
					[TriggerTypeId]
					,[Name]
					,[Description]
					,[CreationCodeId]
					,[Archived]
					,[LastOperation]
					)
				VALUES
					(
					@TriggerTypeId
					,@Name
					,@Description
					,@CreationCodeId
					,@Archived
					,@LastOperation
					)
				
									
							
			


GO
