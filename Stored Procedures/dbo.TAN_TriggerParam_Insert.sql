SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the TAN_TriggerParam table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_TriggerParam_Insert]
(

	@TriggerId uniqueidentifier   ,

	@TriggerParamTypeId int   ,

	@TriggerParamTypeValue varchar (255)  ,

	@Archived bit   ,

	@LastOperation smalldatetime   ,

	@Count bigint   
)
AS


				
				INSERT INTO [dbo].[TAN_TriggerParam]
					(
					[TriggerId]
					,[TriggerParamTypeId]
					,[TriggerParamTypeValue]
					,[Archived]
					,[LastOperation]
					,[Count]
					)
				VALUES
					(
					@TriggerId
					,@TriggerParamTypeId
					,@TriggerParamTypeValue
					,@Archived
					,@LastOperation
					,@Count
					)
				
									
							
			


GO
