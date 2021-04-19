SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_WriteVideoEventVideo]
	@projectid VARCHAR(1024),
	@vehicleId UNIQUEIDENTIFIER,
	@cameraId UNIQUEIDENTIFIER,
    @apiEventId VARCHAR(1024),
		
	@apiVideoId VARCHAR(1024),
	@apiStartTime DATETIME = NULL,
	@apiEndTime DATETIME = NULL ,	    
	@apiFileName VARCHAR(1024),
	@cameraNumber INT,
    
	@eventVideoId BIGINT=NULL OUTPUT  
AS 

	--Write the data to the CAM_VideoIn table for processing later
	INSERT INTO dbo.CAM_VideoIn
	        ( ApiEventId,
	          ApiVideoId,
	          ApiFileName,
	          ApiStartTime,
	          ApiEndTime,
	          CameraNumber,
	          LastOperation,
	          Archived,
			  VideoStatus
	        )
	VALUES  ( @apiEventId, -- ApiEventId
	          @apiVideoId, -- ApiVideoId
	          @apiFileName, -- ApiFileName
	          @apiStartTime, -- ApiStartTime
	          @apiEndTime, -- ApiEndTime
	          @cameraNumber, -- CameraNumber
	          GETDATE(), -- LastOperation
	          0,  -- Archived
			  1 -- Video Status (allways Complete, because this SP is called only for complete videos)
	        )

	SET @eventVideoId = SCOPE_IDENTITY()

GO
