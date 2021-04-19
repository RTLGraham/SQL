SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[proc_Report_DriverNotification]
(
	@gids NVARCHAR(MAX),
	@vids NVARCHAR(MAX),
	@sdate DATETIME,
	@edate DATETIME,
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @gids NVARCHAR(MAX),
--		@vids NVARCHAR(MAX),
--		@uid UNIQUEIDENTIFIER,
--		@sdate DATETIME,
--		@edate DATETIME

--SET @gids = 'EA6FF8F6-F6EA-4632-9607-7B0A8A8A8DDB,C1234FEF-CE3B-4826-9FE8-B8560690165B,D44A8BB9-283D-4D6D-9FC3-1BB5DE7AD088,D2B5005D-E9C1-4B42-A0C9-0C56B704A392'
--SET @vids = '909FB8A2-A973-4253-99C1-03EAF670C13B,9F754430-BDF3-4F5A-9454-092C21FE247A,ABAC69E6-CCCC-4E60-9F81-0B14A2CE8CFD,7A03DFD2-3982-46E8-8C4E-12F297DEE350,97F53C63-1B1D-4760-9DE9-2B09A740A513,901BCFF8-BE83-4C2C-90E2-A7E0C80A1D99'
--SET @uid = 'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'
--SET @sdate = '2012-09-01 00:00'
--SET @edate = '2012-09-30 23:59'

SET @sdate = [dbo].TZ_ToUTC(@sdate,default,@uid)
SET @edate = [dbo].TZ_ToUTC(@edate,default,@uid)

SELECT  
		g.GroupId,
		g.GroupName,
		
		v.VehicleId,
        v.Registration,

		[dbo].[TZ_GetTime](dbo.TZ_ToUtc(dn.LastOperation, 'GMT Time', NULL), default, @uid) AS DNTime,
        dn.Status AS DNStatus,
		        
        --[dbo].[GetGeofenceNameFromLongLat](dn.Lat, dn.Long, @uid, [dbo].[GetAddressFromLongLat](dn.Lat, dn.Long)) as ReverseGeoCode,
        
        CASE WHEN [dbo].[GetGeofenceNameFromLongLat](dn.Lat, dn.Long, @uid, [dbo].[GetAddressFromLongLat](dn.Lat, dn.Long)) IS NULL AND 
				  dn.Lat IS NOT NULL AND 
				  dn.Long IS NOT NULL
			 THEN dbo.fn_GetAddressFromService(dn.Lat, dn.Long)
			 ELSE [dbo].[GetGeofenceNameFromLongLat](dn.Lat, dn.Long, @uid, [dbo].[GetAddressFromLongLat](dn.Lat, dn.Long))
			 END
		AS ReverseGeoCode,
        
        dn.Lat,
        dn.Long,
        
        u.UserID,
        u.Name,
        u.FirstName,
        u.Surname
        
FROM    dbo.DriverNotification dn
		LEFT OUTER JOIN dbo.[User] u ON dn.UserId = u.UserID
        INNER JOIN dbo.Vehicle v ON dn.VehicleId = v.VehicleId
        INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
        INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
WHERE   v.VehicleId IN ( SELECT Value
                         FROM   dbo.Split(@vids, ',') )
		AND gd.GroupTypeId = 1 AND g.Archived = 0 AND g.GroupTypeId = 1 AND g.IsParameter = 0 
		AND g.GroupId IN (SELECT Value 
						  FROM   dbo.Split(@gids, ',') )
		AND dn.LastOperation BETWEEN dbo.TZ_GetTime(@sdate, 'GMT Time', NULL)
								AND  dbo.TZ_GetTime(@edate, 'GMT Time', NULL)
ORDER BY g.GroupName ASC, v.Registration ASC, dn.LastOperation DESC
GO
