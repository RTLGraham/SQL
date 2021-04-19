SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*
----------------------------------------------------------------------------------------------------

-- Created By: RTL Systems Ltd (http://www.rtlsystems.co.uk)
-- Purpose: Select records from the Driver table through an index
----------------------------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[Driver_GetByDriverIntId]
(

	@DriverIntId int   
)
AS


				SELECT
					DriverId ,
                    DriverIntId ,
                    Number ,
                    NumberAlternate ,
                    NumberAlternate2 ,
                    FirstName ,
                    Surname ,
                    MiddleNames ,
                    LastOperation ,
                    Archived ,
                    LanguageCultureId ,
                    LicenceNumber ,
                    IssuingAuthority ,
                    LicenceExpiry ,
                    MedicalCertExpiry ,
                    Password
				FROM
					[dbo].[Driver]
				WHERE
					[DriverIntId] = @DriverIntId
                                AND
                            Archived = 0
				SELECT @@ROWCOUNT
					
			



GO
