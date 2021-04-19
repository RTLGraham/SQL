SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_TrackByTrackerNumber]
    (
      @TrackerNumbers NVARCHAR(MAX)
    )
AS 
	--DECLARE @TrackerNumbers NVARCHAR(MAX)
	--SET @TrackerNumbers = '123456789'
	
	
	SELECT  v.VehicleId,
			v.Registration,
			i.IVHId,
			i.TrackerNumber,
			i.PhoneNumber,
			vle.Lat,
			vle.Long,
			vle.Heading,
			vle.Speed,
			vle.EventDateTime,
			vle.VehicleMode AS VehicleModeId
	FROM dbo.VehicleLatestEvent vle
		INNER JOIN dbo.Vehicle v ON vle.VehicleId = v.VehicleId
		INNER JOIN dbo.IVH i ON v.IVHId = i.IVHId
	WHERE v.Archived = 0 AND i.Archived = 0
		AND i.TrackerNumber IN (SELECT Value FROM dbo.Split(@TrackerNumbers, ','))

GO
