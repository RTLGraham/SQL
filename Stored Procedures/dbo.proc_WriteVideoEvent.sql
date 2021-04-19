SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_WriteVideoEvent]
	@projectid VARCHAR(1024),
	@vehicleId UNIQUEIDENTIFIER,
	@cameraId UNIQUEIDENTIFIER,
    @apiEventId VARCHAR(1024),
    
    @eventdt DATETIME,
	@lat float, 
    @long float, 
	@speed smallint,
	@heading smallint, 
    
	@eid BIGINT=NULL OUTPUT  
AS 
	
	--Write the data to the CAM_EventIn table for processing later
	INSERT INTO dbo.CAM_EventIn
	        ( ProjectId,
	          VehicleId,
			  EventDateTime,
	          ApiEventId,
	          CameraId,
	          Lat,
	          Long,
	          Speed,
	          Heading,
	          LastOperation,
	          Archived
	        )
	VALUES  ( @projectid, -- ProjectId,
			  @vehicleId, -- VehicleId,
			  @eventdt, -- EventDateTime
	          @apiEventId, -- ApiEventId
	          @CameraId, -- CameraId
	          @lat, -- Lat
	          @long, -- Long
	          @speed, -- Speed
	          @heading, -- Heading
	          GETDATE(), -- LastOperation
	          0  -- Archived
	        )

	SET @eid = SCOPE_IDENTITY()

GO
