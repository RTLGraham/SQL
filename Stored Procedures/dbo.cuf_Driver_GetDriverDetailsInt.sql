SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_GetDriverDetailsInt]
(
	@did INT,
	@uid UNIQUEIDENTIFIER,
	@date DATETIME = NULL
)
AS
	DECLARE @vid UNIQUEIDENTIFIER
	
	-- Get basic driver details
	SELECT
		d.[DriverId],
		d.[DriverIntId],
		d.[Number],
		d.[NumberAlternate],
		d.[NumberAlternate2],
		d.[FirstName],
		d.[Surname],
		d.[MiddleNames],
		d.[LastOperation],
		d.[Archived],
		d.[LanguageCultureId],
		d.[LicenceNumber],
		d.[IssuingAuthority],
		d.[LicenceExpiry],
		d.[MedicalCertExpiry],
		d.[Password],
		dbo.FormatDriverNameByUser(d.DriverId, @uid) AS DisplayName
	FROM
		[dbo].[Driver] d
	WHERE DriverIntId = @did

	DECLARE @today DATETIME
	SET @today = (SELECT TOP 1 GetDate())
	
	-- Get details of which vehicle the driver is currently driving
	SET @vid = (SELECT TOP 1 VehicleId
				FROM [dbo].[VehicleLatestEvent] e
					INNER JOIN Driver d ON e.DriverId = d.DriverId
				WHERE d.DriverIntId = @did 
				--AND LatestEventDateTime > DateAdd(day, DatePart(day, @today - 1), @today)
				GROUP BY VehicleId, EventDateTime
				ORDER BY EventDateTime DESC
	)

	EXECUTE cuf_Vehicle_GetVehicleDetails @vid, @uid, @date




GO
