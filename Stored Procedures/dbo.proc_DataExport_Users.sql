SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[proc_DataExport_Users]
(
	@uid UNIQUEIDENTIFIER
)
AS

--DECLARE	@uid UNIQUEIDENTIFIER
--SET @uid = N'3C65E267-ED53-4599-98C5-CBF5AFD85A66'

DECLARE @User TABLE	
(
	UserId UNIQUEIDENTIFIER
)

INSERT INTO @User (UserId)
SELECT u.UserId
FROM dbo.[User] iu
	INNER JOIN dbo.Customer c ON c.CustomerId = iu.CustomerID
	INNER JOIN dbo.[User] u ON u.CustomerID = c.CustomerId
WHERE iu.UserID = @uid
  AND u.Archived = 0

SELECT 
	c.Name AS CustomerName,
    det.Name,
    det.Email,
    det.Location,
    det.FirstName,
    det.Surname,
    det.ExpiryDate,
	dbo.TZ_GetTime(log.LastLoggedIn, DEFAULT, det.UserID) AS LastLoggedIn,
	STUFF((SELECT DISTINCT '; ' + g.GroupName
            FROM @User u
				INNER JOIN dbo.UserGroup ug ON u.UserID = ug.UserId
				INNER JOIN dbo.[Group] g ON g.GroupId = ug.GroupId
				INNER JOIN dbo.GroupDetail gd ON ug.GroupId = gd.GroupId
            WHERE u.Userid = ui.UserId
			  AND g.Archived = 0 AND g.IsParameter = 0 AND g.GroupTypeId = 1
            FOR XML PATH('')),1,1,'') AS VehicleGroups,
	STUFF((SELECT DISTINCT '; ' + g.GroupName
            FROM @User u
				INNER JOIN dbo.UserGroup ug ON u.UserID = ug.UserId
				INNER JOIN dbo.[Group] g ON g.GroupId = ug.GroupId
				INNER JOIN dbo.GroupDetail gd ON ug.GroupId = gd.GroupId
            WHERE u.Userid = ui.UserId
			  AND g.Archived = 0 AND g.IsParameter = 0 AND g.GroupTypeId = 2
            FOR XML PATH('')),1,1,'') AS DriverGroups,
	STUFF((SELECT DISTINCT '; ' + g.GroupName
            FROM @User u
				INNER JOIN dbo.UserGroup ug ON u.UserID = ug.UserId
				INNER JOIN dbo.[Group] g ON g.GroupId = ug.GroupId
				INNER JOIN dbo.GroupDetail gd ON ug.GroupId = gd.GroupId
            WHERE u.Userid = ui.UserId
			  AND g.Archived = 0 AND g.IsParameter = 0 AND g.GroupTypeId = 4
            FOR XML PATH('')),1,1,'') AS GeofenceGroups

FROM @User ui
INNER JOIN dbo.[User] det ON det.UserID = ui.UserId
INNER JOIN dbo.Customer c ON c.CustomerId = det.CustomerID
LEFT JOIN (SELECT us.Userid, MAX(us.LastOperation) AS LastLoggedIn
			FROM dbo.UserSession us
			INNER JOIN @User u ON u.UserId = us.UserID
			GROUP BY us.UserID) log ON log.UserID = det.UserID

GO
