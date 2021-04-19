SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the TAN_Trigger table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TAN_Trigger_Insert]
(

	@TriggerId uniqueidentifier   ,

	@TriggerTypeId int   ,

	@Name varchar (255)  ,

	@Description varchar (MAX)  ,

	@Disabled bit   ,

	@Archived bit   ,

	@LastOperation smalldatetime   ,

	@CustomerId uniqueidentifier   ,

	@CreatedBy uniqueidentifier   ,

	@Count bigint   
)
AS


				
				INSERT INTO [dbo].[TAN_Trigger]
					(
					[TriggerId]
					,[TriggerTypeId]
					,[Name]
					,[Description]
					,[Disabled]
					,[Archived]
					,[LastOperation]
					,[CustomerId]
					,[CreatedBy]
					,[Count]
					)
				VALUES
					(
					@TriggerId
					,@TriggerTypeId
					,@Name
					,@Description
					,@Disabled
					,@Archived
					,@LastOperation
					,@CustomerId
					,@CreatedBy
					,@Count
					)
				
									
							
			


GO
