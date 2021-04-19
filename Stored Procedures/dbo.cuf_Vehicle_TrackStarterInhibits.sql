SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_TrackStarterInhibits]
(
	@gids NVARCHAR(MAX),
	@vids NVARCHAR(MAX),
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE @gids NVARCHAR(MAX),
--		@vids NVARCHAR(MAX),
--		@uid UNIQUEIDENTIFIER

--SET @gids = 'EA6FF8F6-F6EA-4632-9607-7B0A8A8A8DDB,C1234FEF-CE3B-4826-9FE8-B8560690165B,D44A8BB9-283D-4D6D-9FC3-1BB5DE7AD088,D2B5005D-E9C1-4B42-A0C9-0C56B704A392'
--SET @vids = '909FB8A2-A973-4253-99C1-03EAF670C13B,9F754430-BDF3-4F5A-9454-092C21FE247A,ABAC69E6-CCCC-4E60-9F81-0B14A2CE8CFD,7A03DFD2-3982-46E8-8C4E-12F297DEE350,97F53C63-1B1D-4760-9DE9-2B09A740A513,901BCFF8-BE83-4C2C-90E2-A7E0C80A1D99'
--SET @uid = 'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

DECLARE @speedmult FLOAT,
		@timediff NVARCHAR(30)
    
SET @speedmult = CAST(dbo.[UserPref](@uid, 208) AS FLOAT)
SET @timediff = dbo.[UserPref](@uid, 600)


SELECT  
		g.GroupId,
		g.GroupName,
		v.VehicleId,
        v.Registration,
        
        ISNULL(vle.VehicleMode, 0) AS VehicleModeId,
        CAST(vle.Speed * @speedmult AS SMALLINT) as Speed,
        
        dbo.[GetGeofenceNameFromLongLat](vle.Lat, vle.Long, @uid, dbo.[GetAddressFromLongLat](vle.Lat, vle.Long)) as ReverseGeoCode,
        vle.Lat,
        vle.Long,
        dbo.[TZ_GetTime](vle.EventDateTime, @timediff, @uid) AS EventDateTime,
        
        ISNULL(vle.AnalogIoAlertTypeId, 22) AS SIStatus,
		--Last time when such DN Status was set
        MAX(dbo.[TZ_GetTime](dbo.TZ_ToUtc(si.LastOperation, 'GMT Time', NULL), @timediff, @uid)) AS SITime
FROM    [dbo].VehicleLatestEvent vle
        INNER JOIN dbo.Vehicle v ON vle.VehicleId = v.VehicleId
        INNER JOIN dbo.GroupDetail gd ON v.VehicleId = gd.EntityDataId
        INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
        LEFT OUTER JOIN dbo.StarterInhibit si ON v.VehicleId = si.VehicleId
                                                     AND vle.AnalogIoAlertTypeId = si.Status
WHERE   v.VehicleId IN ( SELECT Value
                         FROM   dbo.Split(@vids, ',') )
		AND gd.GroupTypeId = 1 AND g.Archived = 0 AND g.GroupTypeId = 1 AND g.IsParameter = 0 
		AND g.GroupId IN (SELECT Value 
						  FROM   dbo.Split(@gids, ',') )
GROUP BY g.GroupId,
		 g.GroupName,
		 v.VehicleId,
         v.Registration,
         vle.VehicleMode,
         vle.Speed,
         vle.Lat,
         vle.Long,
         vle.EventDateTime,
         vle.AnalogIoAlertTypeId
OPTION  ( KEEPFIXED PLAN )


GO
