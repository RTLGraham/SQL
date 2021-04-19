SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the VehicleCommand table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[VehicleCommand_Find]
(

	@SearchUsingOR bit   = null ,

	@IvhId uniqueidentifier   = null ,

	@Command binary (1024)  = null ,

	@ExpiryDate smalldatetime   = null ,

	@AcknowledgedDate smalldatetime   = null ,

	@LastOperation smalldatetime   = null ,

	@Archived bit   = null ,

	@CommandId int   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [IVHId]
	, [Command]
	, [ExpiryDate]
	, [AcknowledgedDate]
	, [LastOperation]
	, [Archived]
	, [CommandId]
    FROM
	[dbo].[VehicleCommand]
    WHERE 
	 ([IVHId] = @IvhId OR @IvhId IS NULL)
	AND ([ExpiryDate] = @ExpiryDate OR @ExpiryDate IS NULL)
	AND ([AcknowledgedDate] = @AcknowledgedDate OR @AcknowledgedDate IS NULL)
	AND ([LastOperation] = @LastOperation OR @LastOperation IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([CommandId] = @CommandId OR @CommandId IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [IVHId]
	, [Command]
	, [ExpiryDate]
	, [AcknowledgedDate]
	, [LastOperation]
	, [Archived]
	, [CommandId]
    FROM
	[dbo].[VehicleCommand]
    WHERE 
	 ([IVHId] = @IvhId AND @IvhId is not null)
	OR ([ExpiryDate] = @ExpiryDate AND @ExpiryDate is not null)
	OR ([AcknowledgedDate] = @AcknowledgedDate AND @AcknowledgedDate is not null)
	OR ([LastOperation] = @LastOperation AND @LastOperation is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([CommandId] = @CommandId AND @CommandId is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
