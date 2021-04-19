SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cuf_Driver_GetByDriverSurname]
(
	@surname NVARCHAR(50)
)
AS
	SELECT
					[DriverId],
					[DriverIntId],
					[Number],
					[NumberAlternate],
					[NumberAlternate2],
					[FirstName],
					[Surname],
					[MiddleNames],
					[LastOperation],
					[Archived],
					[LanguageCultureId],
					[LicenceNumber],
					[IssuingAuthority],
					[LicenceExpiry],
					[MedicalCertExpiry],
                    [Password]
				FROM
					[dbo].[Driver]
	WHERE Surname LIKE '%' + @surname + '%'


GO
