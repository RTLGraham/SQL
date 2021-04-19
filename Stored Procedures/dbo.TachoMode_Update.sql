SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Updates a record in the TachoMode table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[TachoMode_Update]
(

	@TachoModeId int   ,

	@OriginalTachoModeId int   ,

	@Name nvarchar (255)  ,

	@Description nvarchar (MAX)  ,

	@Archived bit   
)
AS


				
				
				-- Modify the updatable columns
				UPDATE
					[dbo].[TachoMode]
				SET
					[TachoModeID] = @TachoModeId
					,[Name] = @Name
					,[Description] = @Description
					,[Archived] = @Archived
				WHERE
[TachoModeID] = @OriginalTachoModeId 
				
			


GO
