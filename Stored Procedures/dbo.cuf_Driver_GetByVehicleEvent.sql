SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Driver_GetByVehicleEvent]
(
	@vid UNIQUEIDENTIFIER,
	@eventdatetime DATETIME
)
AS
	SELECT TOP 1
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
        d.[Password]
	FROM [dbo].EventData ed
		INNER JOIN [dbo].[Driver] d ON ed.DriverIntId = d.DriverIntId
	WHERE ed.VehicleIntId = dbo.GetVehicleIntFromId(@vid)
	  AND ed.EventDateTime BETWEEN DATEADD(dd, -1, @eventdatetime) AND @eventdatetime
	  AND ed.EventDataName = 'DID'
	  AND ed.CreationCodeId = 0
	ORDER BY ed.EventDateTime DESC



GO
