SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[cuf_Driver_GetOrCreateFullLookup]
	@customerId UNIQUEIDENTIFIER,
	@number NVARCHAR(32),

	@surname VARCHAR(50) = NULL,
	@firstName VARCHAR(50) = NULL,
	@numberAlternative NVARCHAR(32) = NULL,
	@numberAlternative2 NVARCHAR(32) = NULL,
	@licenseNumber NVARCHAR(30) = NULL,
	@empNumber NVARCHAR(30) = NULL
AS
	/********************************************************************************************************/
	/* Looks up the driver by @number for a spectified customer (@customerId).								*/
	/* @number is checked towards Number, NumberAlternate, and NumberAlternate2 columns on the Driver table */
	/* If a driver is not found, we create using the additional NULL-able fields if the surname is provided	*/
	/* Returns the Driver ID and Int ID																		*/
	/********************************************************************************************************/

	--DECLARE @fmtonlyon bit
	--SELECT @fmtonlyon = 0
	---- this will evaluate to true when FMTONLY is ON, because 'if' statements aren't actually evaluated.
	--IF 1 = 0 SELECT @fmtonlyon = 1
	--SET FMTONLY OFF
	
	
	--IF @fmtonlyon = 1 
	--BEGIN
	--	SET FMTONLY ON
	--	DECLARE @results TABLE
	--	(
	--		DriverId UNIQUEIDENTIFIER,
	--		DriverIntId INT
	--	)
	--	SELECT * FROM @results
	--	RETURN
	--END
	--ELSE 
	--BEGIN
		DECLARE @did UNIQUEIDENTIFIER,
				@dintid INT

		SET @did = dbo.GetDriverIdFromNumberAndCustomerFullLookup(@customerId, @number, @licenseNumber, @empNumber)

		IF @did IS NULL AND @surname IS NOT NULL 
		BEGIN
			-- driver not found and details provided so create one
			SET @did = NEWID()
			DECLARE @tmp TABLE
			(
				MessageId INT,
				ChatroomId INT,
				MessageText NVARCHAR(MAX),
				SenderName NVARCHAR(MAX),
				SenderID UNIQUEIDENTIFIER,
				TimeSent DATETIME,
				ParticipantId UNIQUEIDENTIFIER,
				LastRequestedId DATETIME
			)
			INSERT INTO @tmp
			EXEC proc_WriteDriver @did, @dintid OUTPUT, @customerId, @number, @surname

			UPDATE dbo.Driver
			SET FirstName = @firstName,
				NumberAlternate = @numberAlternative,
				NumberAlternate2 = @numberAlternative2,
				LicenceNumber = @licenseNumber,
				EmpNumber = @empNumber
			WHERE DriverIntId = @dintid
		END

		IF @did IS NULL
		BEGIN
			-- we haven't found or created a driver so just return the number provide back as the surname
			SELECT NULL AS DriverId,
				   NULL AS DriverIntId,
				   @number AS Surname
		END ELSE	
		BEGIN
			-- we have found, or created, a driver so return the key information
			SELECT
				DriverId ,
				DriverIntId ,
				Surname
			FROM dbo.Driver
			WHERE DriverId = @did
		END	
	--END

GO
