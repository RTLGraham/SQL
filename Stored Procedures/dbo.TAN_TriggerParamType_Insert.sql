SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the TAN_TriggerParamType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerParamType_Insert]
(

	@TriggerParamTypeId int   ,

	@Name varchar (255)  ,

	@Description varchar (MAX)  ,

	@Archived bit   ,

	@LastOperation smalldatetime   
)
AS


				
				INSERT INTO [dbo].[TAN_TriggerParamType]
					(
					[TriggerParamTypeId]
					,[Name]
					,[Description]
					,[Archived]
					,[LastOperation]
					)
				VALUES
					(
					@TriggerParamTypeId
					,@Name
					,@Description
					,@Archived
					,@LastOperation
					)
				
									
							
			


GO
