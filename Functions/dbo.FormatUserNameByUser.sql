SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[FormatUserNameByUser]
(
	@userid UNIQUEIDENTIFIER,
	@uid UNIQUEIDENTIFIER
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

	--DECLARE @userid UNIQUEIDENTIFIER,
	--		@uid UNIQUEIDENTIFIER
	--SET @userid = N'C13C0754-8B33-49BA-8C93-C5CE1A5F6475'
	--SET @uid = N'C13C0754-8B33-49BA-8C93-C5CE1A5F6475'

	DECLARE @firstname NVARCHAR(MAX),
			@surname NVARCHAR(MAX),
			@email NVARCHAR(MAX),
			@format VARCHAR(MAX),
			@result VARCHAR(MAX)
				
	SELECT @format = [dbo].UserPref(@uid, 219)
	SET @format = ISNULL(@format, '{0}, {1}') -- set default username format

	SELECT	@surname = Surname,
			@firstname = FirstName,
			@email = Email
	FROM	dbo.[User]
	WHERE	UserID = @userid
	
	SET @format = REPLACE(@format, '{0}', @surname)
	SET @format = REPLACE(@format, '{1}', ISNULL(@firstname,''))
	SET @format = REPLACE(@format, '{2}', ISNULL(@email, ''))
	SET @result = LTRIM(RTRIM(REPLACE(@format, '  ', ' '))) -- clean up additional spaces
	
	RETURN @result

END
GO
