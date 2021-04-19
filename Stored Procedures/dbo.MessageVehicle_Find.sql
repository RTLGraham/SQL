SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Finds records in the MessageVehicle table passing nullable parameters
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[MessageVehicle_Find]
(

	@SearchUsingOR bit   = null ,

	@MessageId int   = null ,

	@VehicleId uniqueidentifier   = null ,

	@UserId uniqueidentifier   = null ,

	@CommandId int   = null ,

	@TimeSent datetime   = null ,

	@MessageStatusHardwareId int   = null ,

	@MessageStatusWetwareId int   = null ,

	@LastModified datetime   = null ,

	@Archived bit   = null ,

	@HasBeenDeleted bit   = null 
)
AS


				
  IF ISNULL(@SearchUsingOR, 0) <> 1
  BEGIN
    SELECT
	  [MessageId]
	, [VehicleId]
	, [UserId]
	, [CommandId]
	, [TimeSent]
	, [MessageStatusHardwareId]
	, [MessageStatusWetwareId]
	, [LastModified]
	, [Archived]
	, [HasBeenDeleted]
    FROM
	[dbo].[MessageVehicle]
    WHERE 
	 ([MessageId] = @MessageId OR @MessageId IS NULL)
	AND ([VehicleId] = @VehicleId OR @VehicleId IS NULL)
	AND ([UserId] = @UserId OR @UserId IS NULL)
	AND ([CommandId] = @CommandId OR @CommandId IS NULL)
	AND ([TimeSent] = @TimeSent OR @TimeSent IS NULL)
	AND ([MessageStatusHardwareId] = @MessageStatusHardwareId OR @MessageStatusHardwareId IS NULL)
	AND ([MessageStatusWetwareId] = @MessageStatusWetwareId OR @MessageStatusWetwareId IS NULL)
	AND ([LastModified] = @LastModified OR @LastModified IS NULL)
	AND ([Archived] = @Archived OR @Archived IS NULL)
	AND ([HasBeenDeleted] = @HasBeenDeleted OR @HasBeenDeleted IS NULL)
	AND Archived = 0
						
  END
  ELSE
  BEGIN
    SELECT
	  [MessageId]
	, [VehicleId]
	, [UserId]
	, [CommandId]
	, [TimeSent]
	, [MessageStatusHardwareId]
	, [MessageStatusWetwareId]
	, [LastModified]
	, [Archived]
	, [HasBeenDeleted]
    FROM
	[dbo].[MessageVehicle]
    WHERE 
	 ([MessageId] = @MessageId AND @MessageId is not null)
	OR ([VehicleId] = @VehicleId AND @VehicleId is not null)
	OR ([UserId] = @UserId AND @UserId is not null)
	OR ([CommandId] = @CommandId AND @CommandId is not null)
	OR ([TimeSent] = @TimeSent AND @TimeSent is not null)
	OR ([MessageStatusHardwareId] = @MessageStatusHardwareId AND @MessageStatusHardwareId is not null)
	OR ([MessageStatusWetwareId] = @MessageStatusWetwareId AND @MessageStatusWetwareId is not null)
	OR ([LastModified] = @LastModified AND @LastModified is not null)
	OR ([Archived] = @Archived AND @Archived is not null)
	OR ([HasBeenDeleted] = @HasBeenDeleted AND @HasBeenDeleted is not null)
	AND Archived = 0
	SELECT @@ROWCOUNT			
  END
				


GO
