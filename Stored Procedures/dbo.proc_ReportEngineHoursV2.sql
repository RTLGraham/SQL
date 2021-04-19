SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[proc_ReportEngineHoursV2]
    @gids NVARCHAR(MAX),
    @vids NVARCHAR(MAX),
    @sdate DATETIME,
    @edate DATETIME,
    @uid UNIQUEIDENTIFIER
AS --DECLARE @gids NVARCHAR(MAX), 
--		@vids NVARCHAR(MAX), 
--		@sdate DATETIME, 
--		@edate DATETIME, 
--		@uid UNIQUEIDENTIFIER
--	
--SET	@gids = N'BB294419-3568-4C19-8A38-B0D3F2C0AB9C'
--SET @vids = N'26D01099-B7AA-4F4A-89D0-8C4B2B33F85B,E5DA9FF2-CBD6-43FC-9F07-BCC4D6197310,DC39BB83-E0E8-4513-88E9-B5C01ED84F34,A1E19612-4D47-4EC9-BBD5-57ADF97ACF88,59A29407-CDA4-48E7-810C-55E7C132FDA2,762FFA13-A345-4BE0-AA7C-58F69C155EA7'
--SET @sdate = '2012-07-17 00:00'
--SET @edate = '2012-07-24 23:59'
--SET @uid = N'A55F77A0-BE2F-4B6F-B6E5-E84B924947F2'

    SET @sdate = [dbo].TZ_ToUTC(@sdate, DEFAULT, @uid)
    SET @edate = [dbo].TZ_ToUTC(@edate, DEFAULT, @uid)

    SELECT  Vehicle.VehicleId,
            Registration,
            [Group].GroupId,
            GroupName,
            TotalTime,
            @sdate AS sdate,
            @edate AS edate
    FROM    ( SELECT    CASE WHEN ( GROUPING(v.VehicleId) = 1 ) THEN NULL
                             ELSE ISNULL(v.VehicleId, NULL)
                        END AS VehicleId,
                        CASE WHEN ( GROUPING(gd.GroupId) = 1 ) THEN NULL
                             ELSE ISNULL(gd.GroupId, NULL)
                        END AS GroupId,
                        ISNULL(SUM(Duration), 0) AS TotalTime
              FROM      dbo.TripsAndStops ts
                        INNER JOIN dbo.Vehicle v ON ts.VehicleIntID = v.VehicleIntId
                        INNER JOIN GroupDetail gd ON gd.EntityDataId = v.VehicleId
                                                     AND gd.GroupId IN (
                                                     SELECT Value
                                                     FROM   dbo.Split(@gids, ',') )
                                                     AND v.VehicleId IN (
                                                     SELECT Value
                                                     FROM   dbo.Split(@vids, ',') )
              WHERE     ts.Timestamp BETWEEN @sdate AND @edate
                        AND VehicleState = 5 -- KeyOff
                        AND Duration < 86400 -- filter out bad data on the assumption that a vehicle will not run for more than 24hrs in a single 'trip'
              GROUP BY  v.VehicleId,
                        gd.GroupId
                        WITH CUBE
            ) CubeResult
            LEFT JOIN dbo.Vehicle ON CubeResult.VehicleId = Vehicle.VehicleId
            LEFT JOIN [Group] ON CubeResult.GroupId = [Group].GroupId
    WHERE   NOT ( CubeResult.GroupId IS NULL
                  AND CubeResult.VehicleId IS NOT NULL
                )
    ORDER BY GroupName,
            Registration



GO
