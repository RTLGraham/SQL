SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Gets all records from the Driver table
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Driver_Get_List]

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
					[MedicalCertExpiry]
				FROM
					[dbo].[Driver]
                WHERE Archived = 0

				SELECT @@ROWCOUNT
			


GO
