SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[cuf_Driver_GetUnassigned]
(
	@uid UNIQUEIDENTIFIER,
	@cid UNIQUEIDENTIFIER
)
AS


--DECLARE @cid UNIQUEIDENTIFIER,
--		@uid UNIQUEIDENTIFIER
		
--SET @cid = N'36993114-90C0-4697-87E6-97C827D8765A'
--SET @uid = N'3DB40C4A-7E79-4F41-8017-DE6E12EC7A20'

DECLARE @timediff NVARCHAR(30)
	
SET @timediff = dbo.[UserPref](@uid, 600)

SELECT c.CustomerId, c.CustomerIntId, 
	d.DriverId, d.DriverIntId, d.Number, d.NumberAlternate, d.NumberAlternate2, d.FirstName, d.MiddleNames, d.Surname, d.LastOperation, e.EventId, v.Registration, 
	dbo.[TZ_GetTime]( e.EventDateTime, @timediff, @uid) AS EventDateTime,
	dbo.IsAlphaNumericDriverNumber(d.Number) AS IsCorrupt
FROM dbo.Driver d 
	INNER JOIN dbo.CustomerDriver cd ON d.DriverId = cd.DriverId
	INNER JOIN dbo.Customer c ON cd.CustomerId = c.CustomerId
	LEFT OUTER JOIN dbo.Event e ON e.EventId = 
		(
			SELECT TOP 1 evt.EventId
			FROM dbo.Event evt
				INNER JOIN dbo.Vehicle veh ON evt.VehicleIntId = veh.VehicleIntId
				INNER JOIN dbo.CustomerVehicle cveh ON veh.VehicleId = cveh.VehicleId
				INNER JOIN dbo.Customer cust ON cveh.CustomerId = cust.CustomerId
			WHERE evt.DriverIntId = d.DriverIntId 
				AND cust.CustomerIntId = c.CustomerIntId
				AND evt.EventDateTime BETWEEN DATEADD(day, -1, d.LastOperation) AND DATEADD(day, 1, d.LastOperation)
			ORDER BY evt.EventId DESC
		)
	LEFT OUTER JOIN dbo.Vehicle v ON e.VehicleIntId = v.VehicleIntId
	LEFT OUTER JOIN dbo.GroupDetail gd ON gd.EntityDataId = d.DriverId
	LEFT OUTER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId AND g.Archived = 0 AND g.IsParameter = 0
WHERE cd.CustomerId = @cid
	AND cd.Archived = 0 AND d.Archived = 0
	AND d.Surname = 'UNKNOWN'
	AND d.Number NOT IN ('No ID', '0')
	AND g.GroupId IS NULL
ORDER BY dbo.IsAlphaNumericDriverNumber(d.Number) ASC, e.EventDateTime DESC	
GO
