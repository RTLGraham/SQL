SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_VT_RequestVideo]
    (
      @vid UNIQUEIDENTIFIER,
      @uid UNIQUEIDENTIFIER,
      @sdate DATETIME
    )
AS 
    
	SET @sdate = [dbo].TZ_ToUTC(@sdate, DEFAULT, @uid)

	DECLARE @cameraSerial VARCHAR(50),
			@cameraID INT

	SELECT	@cameraID = cam.CameraIntId,
			@cameraSerial = cam.Serial
	FROM dbo.Camera cam
		INNER JOIN dbo.VehicleCamera vc ON vc.CameraId = cam.CameraId
		INNER JOIN dbo.Vehicle v ON v.VehicleId = vc.VehicleId
	WHERE v.VehicleId = @vid AND v.Archived = 0 AND vc.Archived = 0 AND vc.EndDate IS NULL AND cam.Archived = 0

	INSERT INTO dbo.VT_CAM_VideoRequest
	        ( StartTime ,
	          CameraIntId ,
	          VideoStatusId ,
	          LastOperation ,
	          Archived
	        )
	VALUES  ( @sdate , -- StartTime - datetime
	          @cameraID , -- CameraIntId - int
	          1 , -- VideoStatusId - int
	          GETDATE() , -- LastOperation - smalldatetime
	          0  -- Archived - bit
	        )


GO
