SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Vehicle_GetVehiclesWithLinkedDrivers]
(
	@userId UNIQUEIDENTIFIER
)
AS
	--DECLARE @userId UNIQUEIDENTIFIER
	--SET @userId = N'0A27CC10-F810-4A23-8949-285D6456385F'
	
	SELECT g.GroupId, g.GroupName, v.VehicleId, v.Registration, d.DriverId, d.FirstName, d.Surname
	FROM dbo.Vehicle v
		LEFT OUTER JOIN dbo.VehicleDriver vd ON vd.VehicleId = v.VehicleId AND vd.EndDate IS NULL AND vd.Archived = 0
		LEFT OUTER JOIN dbo.Driver d ON d.DriverId = vd.DriverId
		INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = v.VehicleId
		INNER JOIN dbo.[Group] g ON g.GroupId = gd.GroupId
		INNER JOIN dbo.UserGroup ug ON ug.GroupId = g.GroupId
	WHERE g.IsParameter = 0 AND g.GroupTypeId = 1 AND v.Archived = 0 AND g.Archived = 0 AND ug.Archived = 0
		AND ug.UserId = @userId
	ORDER BY g.GroupName, v.Registration

GO
