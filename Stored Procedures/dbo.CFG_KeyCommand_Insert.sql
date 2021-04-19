SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Inserts a record into the CFG_KeyCommand table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_KeyCommand_Insert]
(

	@KeyCommandId int    OUTPUT,

	@CategoryId int   ,

	@CommandId int   ,

	@KeyId int   ,

	@MinValue float   ,

	@MaxValue float   ,

	@MinDate datetime   ,

	@MaxDate datetime   ,

	@LastOperation smalldatetime   
)
AS


				/*Legacy*/
				--INSERT INTO [dbo].[CFG_KeyCommand]
				--	(
				--	[CategoryId]
				--	,[CommandId]
				--	,[KeyId]
				--	,[MinValue]
				--	,[MaxValue]
				--	,[MinDate]
				--	,[MaxDate]
				--	,[LastOperation]
				--	)
				--VALUES
				--	(
				--	@CategoryId
				--	,@CommandId
				--	,@KeyId
				--	,@MinValue
				--	,@MaxValue
				--	,@MinDate
				--	,@MaxDate
				--	,@LastOperation
				--	)
				
				---- Get the identity value
				--SET @KeyCommandId = SCOPE_IDENTITY()
									
							
			


GO
