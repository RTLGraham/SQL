SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Driver_GetByCustomerIntId]
(
	@CustomerIntId INT
)
AS
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
		d.[Password]
	FROM
		[dbo].[Driver] d
		INNER JOIN [dbo].[CustomerDriver] cd ON d.DriverId = cd.DriverId
		INNER JOIN dbo.Customer c ON cd.CustomerId = c.CustomerId
	WHERE c.CustomerIntId = @CustomerIntId
		AND cd.Archived = 0
		AND (cd.EndDate IS NULL OR cd.EndDate > GETDATE())



GO
