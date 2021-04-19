SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Driver_AdminUpdate]
(
	@DriverId UNIQUEIDENTIFIER,
	@Surname VARCHAR(50) = NULL,
	@Firstname VARCHAR(50) = NULL,
	@Middlenames VARCHAR(250) = NULL,
	@Number VARCHAR(32) = NULL,
	@NumberAlternate VARCHAR(32) = NULL,
	@NumberAlternate2 VARCHAR(32) = NULL,
	@LanguageCultureId SMALLINT = NULL,
	@LicenceNumber NVARCHAR(30) = NULL,
	@IssuingAuthority NVARCHAR(20) = NULL,
	@LicenceExpiry SMALLDATETIME = NULL,
	@MedicalCertExpiry SMALLDATETIME = NULL,
	@password VARCHAR(32) = NULL,
	@playInd BIT = NULL,
	@driverType VARCHAR(100) = NULL,
	@empNumber VARCHAR(30) = NULL,
	@email VARCHAR(100) = NULL
)
AS
BEGIN
	BEGIN TRAN
	UPDATE dbo.Driver
	SET Surname = @Surname,
		FirstName = @Firstname,
		MiddleNames = @Middlenames,
		Number = @Number,
		NumberAlternate = @NumberAlternate,
		NumberAlternate2 = @NumberAlternate2,
		LastOperation = GETDATE(),
		LanguageCultureId = @LanguageCultureId,
		LicenceNumber = @LicenceNumber,
		IssuingAuthority = @IssuingAuthority,
		LicenceExpiry = @LicenceExpiry,
		MedicalCertExpiry = @MedicalCertExpiry,
		[Password] = @password,
		PlayInd = @playInd,
		DriverType = @driverType,
		EmpNumber = @empNumber,
		Email = @email
	WHERE DriverId = @DriverId
	
	
	/*Archive UNKNOW driver is there is any*/
	UPDATE dbo.Driver
	SET Archived = 1
	WHERE DriverId IN	(
						SELECT d.DriverId
						FROM dbo.Driver d
							INNER JOIN dbo.CustomerDriver cd ON d.DriverId = cd.DriverId
						WHERE d.Number IN (@Number, @NumberAlternate, @NumberAlternate2)
							AND d.Surname = 'UNKNOWN' AND d.Archived = 0
							AND cd.CustomerId IN (	SELECT DISTINCT CustomerId 
													FROM dbo.CustomerDriver 
													WHERE DriverId = @DriverId)
						)
	
	UPDATE dbo.CustomerDriver
	SET Archived = 1
	WHERE DriverId IN	(
						SELECT d.DriverId
						FROM dbo.Driver d
							INNER JOIN dbo.CustomerDriver cd ON d.DriverId = cd.DriverId
						WHERE d.Number IN (@Number, @NumberAlternate, @NumberAlternate2)
							AND d.Surname = 'UNKNOWN' AND d.Archived = 0
							AND cd.CustomerId IN (	SELECT DISTINCT CustomerId 
													FROM dbo.CustomerDriver 
													WHERE DriverId = @DriverId)
						)
		AND CustomerId IN (	SELECT DISTINCT CustomerId 
							FROM dbo.CustomerDriver 
							WHERE DriverId = @DriverId)
	
	
	COMMIT TRAN
END

GO
