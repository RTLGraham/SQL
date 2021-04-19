SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[proc_VT_GetRequestedVideos]
    (
      @vids NVARCHAR(MAX),
      @uid UNIQUEIDENTIFIER,
      @sdate DATETIME,
      @edate DATETIME
    )
AS 

	SELECT v.VehicleId, v.Registration, cam.CameraId, cam.Serial, 
		vr.VideoRequestId ,
        vr.RequestId ,
        vr.StartTime ,
        vr.VideoStatusId ,
		vs.Name AS VideoStatus
	FROM dbo.VT_CAM_VideoRequest vr
		INNER JOIN dbo.Camera cam ON cam.CameraIntId = vr.CameraIntId
		INNER JOIN dbo.VehicleCamera vc ON vc.CameraId = cam.CameraId
		INNER JOIN dbo.Vehicle v ON v.VehicleId = vc.VehicleId
		INNER JOIN dbo.VT_CAM_VideoStatus vs ON vr.VideoStatusId = vs.VideoStatusId
	WHERE vr.StartTime BETWEEN @sdate AND @edate
		AND v.VehicleId IN (SELECT Value FROM dbo.Split(@vids, ','))
		AND vr.Archived = 0
	ORDER BY vr.VideoRequestId DESC
    

GO
