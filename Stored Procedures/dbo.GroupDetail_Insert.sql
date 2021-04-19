SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the GroupDetail table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[GroupDetail_Insert]
(

	@GroupId uniqueidentifier   ,

	@GroupTypeId int   ,

	@EntityDataId uniqueidentifier   
)
AS


				
				INSERT INTO [dbo].[GroupDetail]
					(
					[GroupId]
					,[GroupTypeId]
					,[EntityDataId]
					)
				VALUES
					(
					@GroupId
					,@GroupTypeId
					,@EntityDataId
					)
				
									
							
			


GO
