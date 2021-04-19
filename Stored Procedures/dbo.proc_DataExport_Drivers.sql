SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[proc_DataExport_Drivers]
(
	@cid UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER
)
AS
--DECLARE @uid UNIQUEIDENTIFIER
--SET @uid = N'3C65E267-ED53-4599-98C5-CBF5AFD85A66'

DECLARE @timezone VARCHAR(255)

SELECT  @timezone = dbo.UserPref(@uid, 600)

SELECT 
	c.Name AS CustomerName,
	
	STUFF((SELECT DISTINCT '; ' + g.GroupName
            FROM dbo.[User] u
				INNER JOIN dbo.UserGroup ug ON u.UserID = ug.UserId
				INNER JOIN dbo.[Group] g ON g.GroupId = ug.GroupId
				INNER JOIN dbo.GroupDetail gd ON ug.GroupId = gd.GroupId
				INNER JOIN dbo.Driver dr ON gd.EntityDataId = dr.DriverId
            WHERE dr.DriverId = d.DriverId
				AND g.Archived = 0 AND g.IsParameter = 0 AND g.GroupTypeId = 2
				AND u.UserID = @uid
            FOR XML PATH('')),1,1,''
    ) AS Groups,
	
	d.FirstName,
	d.MiddleNames,
	d.Surname,
	
	CASE WHEN d.Number IS NOT NULL AND LEN(d.Number) = 14
		THEN SUBSTRING(d.Number, 9, 2) + SUBSTRING(d.Number, 7, 2) + SUBSTRING(d.Number, 5, 2) + SUBSTRING(d.Number, 3, 2)
		ELSE NULL
	END AS KissKey,
	d.Number AS Number_KissKey,
	d.NumberAlternate AS Number_TachoCard,
	d.NumberAlternate2 AS Number_Alternative,
	
	[dbo].[TZ_GetTime](dle.EventDateTime, @timezone, @uid) AS LastPoll,
	 
	v.Registration AS AssignedVehicle,
	
	lc.Name AS [Language],
	d.LicenceNumber,
	d.IssuingAuthority AS LicenceIssuingAuthority,
	d.LicenceExpiry,
	d.MedicalCertExpiry,
	d.[Password],
	d.DriverType,
	d.PlayInd,
	STUFF((SELECT DISTINCT '; ' + v.Registration
            FROM dbo.Vehicle v
				INNER JOIN dbo.VehicleDriver vd ON vd.VehicleId = v.VehicleId
				
            WHERE vd.DriverId = d.DriverId
				AND v.Archived = 0 AND vd.EndDate IS NULL AND vd.Archived = 0
            FOR XML PATH('')),1,1,''
    ) AS AssignedToVehicles
			
FROM dbo.Driver d
	LEFT OUTER JOIN dbo.LanguageCulture lc ON d.LanguageCultureId = lc.LanguageCultureID
	LEFT OUTER JOIN dbo.VehicleDriver vd ON d.DriverId = vd.DriverId 
														 AND vd.Archived = 0
	LEFT OUTER JOIN dbo.Vehicle v ON v.VehicleId = vd.VehicleId
	LEFT OUTER JOIN dbo.DriverLatestEvent dle ON d.DriverId = dle.DriverId
	INNER JOIN dbo.GroupDetail gd ON gd.EntityDataId = d.DriverId
	INNER JOIN dbo.[Group] g ON gd.GroupId = g.GroupId
	INNER JOIN dbo.UserGroup ug ON g.GroupId = ug.GroupId
	INNER JOIN dbo.[User] u ON ug.UserId = u.UserID
	INNER JOIN dbo.CustomerDriver cd ON cd.DriverId = d.DriverId
	INNER JOIN dbo.Customer c ON cd.CustomerId = c.CustomerId AND c.CustomerId = u.CustomerID
WHERE u.UserID = @uid
	AND d.Archived = 0
GROUP BY c.Name, d.DriverId, d.DriverIntId, d.FirstName, d.MiddleNames, d.Surname, d.Number, d.NumberAlternate, d.NumberAlternate2, dle.EventDateTime,
	v.Registration, lc.Name, d.LicenceNumber, d.IssuingAuthority, d.LicenceExpiry, d.MedicalCertExpiry, d.[Password], d.DriverType, d.PlayInd
ORDER BY c.Name, d.Surname

GO
