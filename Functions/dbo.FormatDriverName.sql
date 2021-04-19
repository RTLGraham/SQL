SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[FormatDriverName]
(
	@drivername NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN

--	DECLARE @driverName NVARCHAR(MAX)
--	SET @drivername = 'John A. Smith'

	DECLARE @firstnames NVARCHAR(MAX)
	DECLARE @surname NVARCHAR(MAX)
	DECLARE @reverse NVARCHAR(MAX)
	
	SET @reverse = REVERSE(@drivername)
	IF CHARINDEX(' ', @drivername) > 0
		SET @surname = RIGHT(@drivername, CHARINDEX(' ', @reverse)-1)
	ELSE
		SET @surname = @drivername
	
	IF CHARINDEX(' ', @drivername) > 0
		SET @firstnames = LEFT(@drivername, LEN(@drivername)-LEN(@surname))

	IF LEN(@surname) = LEN(@drivername)
		SET @driverName = @surname
	ELSE
		SET @drivername = @surname + ' ' + @firstnames
		
	RETURN @drivername
END


GO
