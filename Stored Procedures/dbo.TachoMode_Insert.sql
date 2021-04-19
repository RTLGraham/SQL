SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the TachoMode table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TachoMode_Insert]
(

	@TachoModeId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				INSERT INTO [dbo].[TachoMode]
					(
					[TachoModeID]
					,[Name]
					,[Description]
					,[Archived]
					)
				VALUES
					(
					@TachoModeId
					,@Name
					,@Description
					,@Archived
					)
				
									
							
			


GO
