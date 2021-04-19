SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[FormatDriverNameByUser]
(
	@driverid UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

	--DECLARE @driverid UNIQUEIDENTIFIER,
	--		@uid UNIQUEIDENTIFIER
	--SET @driverid = N'70277752-9849-E111-A26E-001C23C37503'
	--SET @uid = N'FE90CE6B-0973-4D7B-8157-1C89CFA422F5'

	DECLARE @firstname NVARCHAR(MAX),
			@surname NVARCHAR(MAX),
			@middlenames NVARCHAR(MAX),
			@format VARCHAR(MAX),
			@obfuscate VARCHAR(1),
			@number VARCHAR(MAX),
			@empnumber VARCHAR(MAX),
			@result VARCHAR(MAX),
			@type VARCHAR(100)

	SELECT	@surname = Surname,
			@firstname = FirstName,
			@middlenames = MiddleNames,
			@number = Number,
			@empnumber = EmpNumber,
			@type = DriverType
	FROM	dbo.Driver
	WHERE	DriverId = @driverid	
	
	SELECT @format = [dbo].UserPref(@uid, 212)
	SELECT @obfuscate = [dbo].UserPref(@uid, 440)
	SET @format = CASE WHEN @obfuscate = '1' AND @type = 'CONTRACTOR' THEN '{3}' ELSE ISNULL(@format, '{0}, {1}') END -- set default if no preference set, or obfuscate if required

	IF @surname = 'UNKNOWN'
	BEGIN
		SET @result = @number
	END
	ELSE
	BEGIN
		SET @format = REPLACE(@format, '{0}', @surname)
		SET @format = REPLACE(@format, '{1}', ISNULL(@firstname,''))
		SET @format = REPLACE(@format, '{2}', ISNULL(@middlenames, ''))
		SET @format = REPLACE(@format, '{3}', ISNULL(@number, ''))
		SET @format = REPLACE(@format, '{4}', ISNULL(@empnumber, ''))
		SET @result = LTRIM(RTRIM(REPLACE(@format, '  ', ' '))) -- clean up additional spaces
	END
	
	RETURN	 @result

END
GO
