SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the WKD_WorkStateType table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[WKD_WorkStateType_Insert]
(

	@WorkStateTypeId int   ,

	@Name varchar (50)  ,

	@Description varchar (MAX)  ,

	@LastModified datetime   ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[WKD_WorkStateType]
					(
					[WorkStateTypeId]
					,[Name]
					,[Description]
					,[LastModified]
					,[Archived]
					)
				VALUES
					(
					@WorkStateTypeId
					,@Name
					,@Description
					,@LastModified
					,@Archived
					)
				
									
							
			


GO
