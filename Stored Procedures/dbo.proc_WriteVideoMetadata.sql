SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[proc_WriteVideoMetadata]
	@projectid VARCHAR(1024),
	@vehicleId UNIQUEIDENTIFIER,
	@cameraId UNIQUEIDENTIFIER,
    @apiEventId VARCHAR(1024),
		
	@apiMetadataId VARCHAR(1024),
	@ccid SMALLINT
    
AS 

	--Write the data to the CAM_MetadataIn table for processing later
	INSERT INTO dbo.CAM_MetadataIn
	        ( CreationCodeId,
	          ApiEventId,
	          ApiMetadataId,
	          LastOperation,
	          Archived
	        )
	VALUES  ( @ccid, -- CreationCodeId
	          @apiEventId, -- ApiEventId
	          @apiMetadataId, -- ApiMetadataId
	          GETDATE(), -- LastOperation
	          0  -- Archived
	        )
GO
