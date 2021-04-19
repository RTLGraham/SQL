SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Vehicle_GetUnassigned]
(
	@uid UNIQUEIDENTIFIER,
	@cid UNIQUEIDENTIFIER
)
AS


--DECLARE @cid UNIQUEIDENTIFIER,
--		@uid UNIQUEIDENTIFIER
		
--SET @cid = N'36993114-90c0-4697-87e6-97c827d8765a'
--SET @uid = N'e3acb89a-e2f7-4325-8f2a-c228ff9056ba'

DECLARE @timediff NVARCHAR(30)
	
SET @timediff = dbo.[UserPref](@uid, 600)


SELECT c.CustomerId, c.CustomerIntId, v.VehicleId,
v.VehicleIntId,v.Registration,v.MakeModel,v.LastOperation

FROM dbo.Vehicle v
INNER JOIN dbo.CustomerVehicle cv ON cv.VehicleId = v.VehicleId
INNER JOIN dbo.Customer c ON c.CustomerId = cv.CustomerId
--LEFT OUTER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
--LEFT OUTER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId AND g.Archived = 0 AND g.IsParameter = 0
WHERE cv.CustomerId = @cid
	AND cv.Archived = 0 AND v.Archived = 0
	--AND d.Surname = 'UNKNOWN'
	AND v.Registration NOT IN ('UNKNOWN', '0')
		AND NOT EXISTS
        (
            SELECT *
            FROM dbo.[GroupDetail] gd
                INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
            WHERE g.IsParameter = 0 AND g.Archived = 0 AND gd.EntityDataId = v.VehicleId
        )
	--AND g.GroupId IS NULL
ORDER BY v.Registration ASC, v.LastOperation DESC	
GO
