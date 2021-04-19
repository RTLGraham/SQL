SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the CFG_Command table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_Command_Find]
(

	@SearchUsingOR bit   = null ,

	@CommandId int   = null ,

	@IvhTypeId int   = null ,

	@CommandString varchar (MAX)  = null ,

	@Description varchar (MAX)  = null ,

	@Archived bit   = null ,

	@LastOperation smalldatetime   = null 
)
AS


  /*Legacy*/					
 -- IF ISNULL(@SearchUsingOR, 0) <> 1
 -- BEGIN
 --   SELECT
	--  [CommandId]
	--, [IVHTypeId]
	--, [CommandString]
	--, [Description]
	--, [Archived]
	--, [LastOperation]
 --   FROM
	--[dbo].[CFG_Command]
 --   WHERE 
	-- ([CommandId] = @CommandId OR @CommandId IS NULL)
	--AND ([IVHTypeId] = @IvhTypeId OR @IvhTypeId IS NULL)
	--AND ([CommandString] = @CommandString OR @CommandString IS NULL)
	--AND ([Description] = @Description OR @Description IS NULL)
	--AND ([Archived] = @Archived OR @Archived IS NULL)
	--AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
	--AND Archived = 0
						
 -- END
 -- ELSE
 -- BEGIN
 --   SELECT
	--  [CommandId]
	--, [IVHTypeId]
	--, [CommandString]
	--, [Description]
	--, [Archived]
	--, [LastOperation]
 --   FROM
	--[dbo].[CFG_Command]
 --   WHERE 
	-- ([CommandId] = @CommandId AND @CommandId is not null)
	--OR ([IVHTypeId] = @IvhTypeId AND @IvhTypeId is not null)
	--OR ([CommandString] = @CommandString AND @CommandString is not null)
	--OR ([Description] = @Description AND @Description is not null)
	--OR ([Archived] = @Archived AND @Archived is not null)
	--OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	--AND Archived = 0
	--SELECT @@ROWCOUNT			
 -- END
				


GO
