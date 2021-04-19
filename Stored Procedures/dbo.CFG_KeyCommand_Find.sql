SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the CFG_KeyCommand table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[CFG_KeyCommand_Find]
(

	@SearchUsingOR bit   = null ,

	@KeyCommandId int   = null ,

	@CategoryId int   = null ,

	@CommandId int   = null ,

	@KeyId int   = null ,

	@MinValue float   = null ,

	@MaxValue float   = null ,

	@MinDate datetime   = null ,

	@MaxDate datetime   = null ,

	@LastOperation smalldatetime   = null 
)
AS


  /*Legacy*/				
 -- IF ISNULL(@SearchUsingOR, 0) <> 1
 -- BEGIN
 --   SELECT
	--  [KeyCommandId]
	--, [CategoryId]
	--, [CommandId]
	--, [KeyId]
	--, [MinValue]
	--, [MaxValue]
	--, [MinDate]
	--, [MaxDate]
	--, [LastOperation]
 --   FROM
	--[dbo].[CFG_KeyCommand]
 --   WHERE 
	-- ([KeyCommandId] = @KeyCommandId OR @KeyCommandId IS NULL)
	--AND ([CategoryId] = @CategoryId OR @CategoryId IS NULL)
	--AND ([CommandId] = @CommandId OR @CommandId IS NULL)
	--AND ([KeyId] = @KeyId OR @KeyId IS NULL)
	--AND ([MinValue] = @MinValue OR @MinValue IS NULL)
	--AND ([MaxValue] = @MaxValue OR @MaxValue IS NULL)
	--AND ([MinDate] = @MinDate OR @MinDate IS NULL)
	--AND ([MaxDate] = @MaxDate OR @MaxDate IS NULL)
	--AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
						
 -- END
 -- ELSE
 -- BEGIN
 --   SELECT
	--  [KeyCommandId]
	--, [CategoryId]
	--, [CommandId]
	--, [KeyId]
	--, [MinValue]
	--, [MaxValue]
	--, [MinDate]
	--, [MaxDate]
	--, [LastOperation]
 --   FROM
	--[dbo].[CFG_KeyCommand]
 --   WHERE 
	-- ([KeyCommandId] = @KeyCommandId AND @KeyCommandId is not null)
	--OR ([CategoryId] = @CategoryId AND @CategoryId is not null)
	--OR ([CommandId] = @CommandId AND @CommandId is not null)
	--OR ([KeyId] = @KeyId AND @KeyId is not null)
	--OR ([MinValue] = @MinValue AND @MinValue is not null)
	--OR ([MaxValue] = @MaxValue AND @MaxValue is not null)
	--OR ([MinDate] = @MinDate AND @MinDate is not null)
	--OR ([MaxDate] = @MaxDate AND @MaxDate is not null)
	--OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	--SELECT @@ROWCOUNT			
 -- END
				


GO
