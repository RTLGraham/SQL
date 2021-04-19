SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the CFG_Command table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_Command_Insert]
(

	@CommandId int    OUTPUT,

	@IvhTypeId int   ,

	@CommandString varchar (MAX)  ,

	@Description varchar (MAX)  ,

	@Archived bit   ,

	@LastOperation smalldatetime   
)
AS


				/*Legacy*/
				
				--INSERT INTO [dbo].[CFG_Command]
				--	(
				--	[IVHTypeId]
				--	,[CommandString]
				--	,[Description]
				--	,[Archived]
				--	,[LastOperation]
				--	)
				--VALUES
				--	(
				--	@IvhTypeId
				--	,@CommandString
				--	,@Description
				--	,@Archived
				--	,@LastOperation
				--	)
				
				---- Get the identity value
				--SET @CommandId = SCOPE_IDENTITY()
									
							
			


GO
